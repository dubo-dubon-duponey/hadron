#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

# Requirements
dc::require jq

HADRON_TARGET_HOST=
HADRON_TARGET_PORT=
HADRON_TARGET_USER=
HADRON_TARGET_IDENTITY=
HADRON_TARGET_CONFIGURED=

HADRON_TARGET_RUN_TAG=
HADRON_TARGET_DESIRED_NETWORKS=
HADRON_TARGET_DESIRED_CONTAINERS=
HADRON_TARGET_DESIRED_IMAGES=

_PRIVATE_HADRON_NETWORK_FORCE_REFRESH=true
_PRIVATE_HADRON_NETWORK_CACHE=
_PRIVATE_HADRON_CONTAINER_FORCE_REFRESH=true
_PRIVATE_HADRON_CONTAINER_CACHE=


hadron_version=v0.1-dev

_hadron::plan::reset(){
  HADRON_TARGET_HOST=
  HADRON_TARGET_PORT=
  HADRON_TARGET_USER=
  HADRON_TARGET_IDENTITY=
  HADRON_TARGET_CONFIGURED=

  # Reset the plan
  HADRON_TARGET_RUN_TAG="$(date "+%Y/%m/%d-%H:%M:%S-$(uuidgen)")"
  HADRON_TARGET_DESIRED_NETWORKS=()
  HADRON_TARGET_DESIRED_CONTAINERS=()
  HADRON_TARGET_DESIRED_IMAGES=()

  _PRIVATE_HADRON_NETWORK_FORCE_REFRESH=true
  _PRIVATE_HADRON_NETWORK_CACHE=
  _PRIVATE_HADRON_CONTAINER_FORCE_REFRESH=true
  _PRIVATE_HADRON_CONTAINER_CACHE=
}

# XXX very dirty temp hack
_hadron::underlying(){
  local one="$1"
  local two="$2"
  local three="$3"
  local four="$4"
  shift
  shift
  shift
  shift
  # XXX -J sshweet
  dc::ssh::client::execute "$one" "$two" "$three" "$four" "$@" <<<"${XXXUBERDIRTY:-}"
}

_hadron::dockerclient(){
  [ "$HADRON_TARGET_CONFIGURED" != "" ] || {
    echo "no ssh host configured. call hadron::connect first"
    exit 1
  }

  # Feed an empty string to stdin so that ssh does not eagerly gobble it up
  # XXX docker login needs stdin support if we don't want to sling env variables around and leak the password
  # Or we manipulate the docker config file directly
#  dc::ssh::client::execute "$HADRON_TARGET_USER" "$HADRON_TARGET_HOST" "$HADRON_TARGET_IDENTITY" "$HADRON_TARGET_PORT" "docker" "$@" <<<""
#  dc::ssh::client::execute "$HADRON_TARGET_USER" "$HADRON_TARGET_HOST" "$HADRON_TARGET_IDENTITY" "$HADRON_TARGET_PORT" -J sshweet "/home/apo/nerdctl" "$@" <<<""
  _hadron::underlying "$HADRON_TARGET_USER" "$HADRON_TARGET_HOST" "$HADRON_TARGET_IDENTITY" "$HADRON_TARGET_PORT" "sudo" "/home/apo/nerdctl" "$@"
#  _hadron::underlying "$HADRON_TARGET_USER" "$HADRON_TARGET_HOST" "$HADRON_TARGET_IDENTITY" "$HADRON_TARGET_PORT" "docker" "$@"
}

hadron::init(){
  # Initialize SSH and point the master connect to hadron prefix
  dc::ssh::client::init "hadron"
  # Initialize the docker client to be our freshly configured ssh+docker provider
  dc::docker::client::init _hadron::dockerclient
}

hadron::customize(){
  local args=()
  local json=". += {"
  local sep=""
  local item
  local key
  local value

  for item in "$@"; do
    key="${item%%=*}"
    value="${item#*=}"
    if [ "${value:0:1}" == "[" ]; then
      args+=("--argjson" "$key" "$value")
    else
      args+=("--arg" "$key" "$value")
    fi
    json+="$sep $key: \$$key"
    sep=","
  done
  json+="}"

  jq "${args[@]}" "$json" <<<"{}"
}

hadron::env(){
  local args=()
  local json=".env += ["
  local sep=""
  local item
  local key
  local value

  for item in "$@"; do
    key="${item%%=*}"
    args+=("--arg" "$key" "$item")
    json+="$sep \$$key"
    sep=","
  done
  json+="]"

  jq "${args[@]}" "$json" <<<"{}"
}

# Allow querying the list of network with caching
hadron::query::network(){
  [ "$_PRIVATE_HADRON_NETWORK_FORCE_REFRESH" != true ] || {
    _PRIVATE_HADRON_NETWORK_FORCE_REFRESH=
    _PRIVATE_HADRON_NETWORK_CACHE="$(dc::docker::client::network::list json)"
  }
  printf "%s" "$_PRIVATE_HADRON_NETWORK_CACHE"
}

hadron::query::container(){
  [ "$_PRIVATE_HADRON_CONTAINER_FORCE_REFRESH" != true ] || {
    _PRIVATE_HADRON_CONTAINER_FORCE_REFRESH=
    _PRIVATE_HADRON_CONTAINER_CACHE="$(dc::docker::client::container::list all json)"
  }
  printf "%s" "$_PRIVATE_HADRON_CONTAINER_CACHE"
}


# Method to start using a given host. Will test it first, then proceed.
# FIXME multiple calls to "connect" will re-test for now. Implement some form of caching as an optimization to save a few seconds.
hadron::connect(){
  local user="${1:-apo}"
  local host="${2:-}"
  local identity="${3:-}"
  local port="${4:-22}"

  dc::logger::info "Connecting to $host"
  # Unconfigured, bail out
  [ "$HADRON_TARGET_CONFIGURED" != true ] || {
    echo "Uncommitted plan. You need to deploy first before you can switch host."
    exit 1
  }

  # XXX FIXME - calling to ssh client that way prevents any specifics of the hadron client implemented above to work
  # For eg: jumpboxes, etc
  # Check that SSH is working - let it through if failing
  _hadron::underlying "$user" "$host" "$identity" "$port" exit 0 || return

  # Check Docker is there
  # XXX make this configurable so we can use containerd
  _hadron::underlying "$user" "$host" "$identity" "$port" command -v /home/apo/nerdctl >/dev/null || {
    echo "Failed to find the docker binary on the remote."
    exit 1
  }

  # Check that docker info is working
  # See above
  _hadron::underlying "$user" "$host" "$identity" "$port" sudo /home/apo/nerdctl info >/dev/null 2>&1 || {
    echo "Failed to run docker info on the remote. Is the daemon started?"
    exit 1
  }

  # All good? Store
  _hadron::plan::reset

  # And set the host props
  HADRON_TARGET_HOST="$host"
  HADRON_TARGET_PORT="$port"
  HADRON_TARGET_USER="$user"
  HADRON_TARGET_IDENTITY="$identity"
  HADRON_TARGET_CONFIGURED=true
}

# Networks do not depend on anything, we can resolve right away
# shellcheck disable=SC2120
hadron::require::network(){
  local description
  local sha

  local args=("$@")
  local key
  local json=''
  local sep=
  local inputs=()
  for key in "${!args[@]}"; do
    json+="$sep .[$key]"
    sep="+"
    inputs+=("${args[${key}]}")
  done
  [ "${#inputs[@]}" != 0 ] || {
    inputs=(/dev/stdin)
    json=".[0]"
  }
  description="$(jq --slurp "$json" "${inputs[@]}")" || return

  sha="$(dc::crypto::shasum::compute <<<"$description")"

  # Otherwise, we will have to create the new one
  HADRON_TARGET_DESIRED_NETWORKS+=("$(printf '{
    "plan": %s,
    "labels": {
      "org.hadron.core.version": "%s",
      "org.hadron.plan.name": "%s",
      "org.hadron.plan.description": "%s",
      "org.hadron.plan.sha": "%s",
      "org.hadron.plan.tag": "%s"
    }
  }' "$description" "$hadron_version" "plan_name" "some_plan_descriptor" "$sha" "$HADRON_TARGET_RUN_TAG")")
}

hadron::container(){
  local description
  local image
  local sha

  local args=("$@")
  local key
  local json=''
  local sep=
  local inputs=()
  for key in "${!args[@]}"; do
    json+="$sep .[$key]"
    sep="+"
    inputs+=("${args[${key}]}")
  done
  [ "${#inputs[@]}" != 0 ] || {
    inputs=(/dev/stdin)
    json=".[0]"
  }
  description="$(jq --slurp "$json" "${inputs[@]}")" || return
  image="$(jq -rc .image - <<<"$description")"
  sha="$(dc::crypto::shasum::compute <<<"$description")"

  # Different sha, or not found to exist will have to create the new one
  HADRON_TARGET_DESIRED_CONTAINERS+=("$(printf '{
    "plan": %s,
    "labels": {
      "org.hadron.core.version": "%s",
      "org.hadron.plan.name": "%s",
      "org.hadron.plan.description": "%s",
      "org.hadron.plan.sha": "%s",
      "org.hadron.plan.tag": "%s"
    }
  }' "$description" "$hadron_version" "plan_name" "some_plan_descriptor" "$sha" "$HADRON_TARGET_RUN_TAG")")

  HADRON_TARGET_DESIRED_IMAGES+=("$image")
}

# shellcheck disable=SC2120
hadron::containerOLD(){
  local description
  local image
  local sha

  # XXX be a lot more defensive here, as empty descriptions will wreak havoc
  description="$(cat "${1:-/dev/stdin}")"
  # >&2 echo "$description"
  image="$(jq -rc .image - <<<"$description")"
  sha="$(dc::crypto::shasum::compute <<<"$description")"

  # Different sha, or not found to exist will have to create the new one
  HADRON_TARGET_DESIRED_CONTAINERS+=("$(printf '{
    "plan": %s,
    "labels": {
      "org.hadron.core.version": "%s",
      "org.hadron.plan.name": "%s",
      "org.hadron.plan.description": "%s",
      "org.hadron.plan.sha": "%s",
      "org.hadron.plan.tag": "%s"
    }
  }' "$description" "$hadron_version" "plan_name" "some_plan_descriptor" "$sha" "$HADRON_TARGET_RUN_TAG")")

  HADRON_TARGET_DESIRED_IMAGES+=("$image")
}

_hadron::deploy::image(){
  local name
  local id
  local new_id

  local candidate

  # Dedup images, as multiple containers may use the same - this works only because images names grammar is restricted
  for name in $(echo "${HADRON_TARGET_DESIRED_IMAGES[@]}" | tr ' ' '\n' | sort | uniq | tr '\n' ' '); do
    # XXX FIXME Docker has an array - containerd a string
    #id="$(jq -rc .[].Id <(dc::docker::client::image::inspect json "$name"))"
    id="$(jq -rc .Id <(dc::docker::client::image::inspect json "$name"))"
    # Force pull it as a check
    dc::docker::client::image::pull "" "$name" >/dev/null
    # XXX FIXME Docker has an array - containerd a string
    #new_id="$(jq -rc .[].Id <(dc::docker::client::image::inspect json "$name"))"
    new_id="$(jq -rc .Id <(dc::docker::client::image::inspect json "$name"))"
    # If we HAD an image like that, go cleanup the containers
    if [ "$id" ] && [ "$new_id" != "$id" ]; then
      # List the containers using the old version of the image and remove them
      while read -r candidate; do
        [ "$candidate" ] || break
        dc::logger::info "   ... removing attached resource $candidate"
        # We are destroying containers - we will need to refresh state
        _PRIVATE_HADRON_CONTAINER_FORCE_REFRESH=true
        # XXX verify what force does, and if it would be better to stop, then rm
        dc::docker::client::container::remove force volumes "$candidate" >/dev/null
      # XXX note: this is going to delete whatever is attached to it, managed or not
      # We could be nicer here
      done < <(jq -r '.Names' <(dc::docker::client::container::list all json ancestor="$id"))
      # Now, GC the previous image
      dc::docker::client::image::remove "" "" "$id" >/dev/null
    fi
  done
#  done < <(jq -rc '. | select(.Labels | test("(^|,)org.hadron.plan.sha=.+")) | .Image' <(hadron::query::container))
}

_hadron::deploy::unit(){
  local type="$1"
  shift
  local key="Name"
  local create="create"
  [ "$type" != "container" ] || {
    key+="s"
    create="run"
  }

  local definition
  local name
  local sha

  local keeplist
  local rmlist
  local addlist
  local keep
  local candidate

  # First, go through the list of objects to add and see if there is any that can be kept
  keeplist=()
  addlist=()
  dc::logger::info "1. looking at desired state to figure out what will need to be created and what can be kept"
  for definition in "$@"; do
    # Extract the name and sha of the object we want to add
    name="$(jq -rc '.plan.name' - <<<"$definition")"
    sha="$(jq -rc '.labels."org.hadron.plan.sha"' - <<<"$definition")"
    dc::logger::info " > examining $name ($sha)"
    # If there is an existing object that matches the sha, mark it as "keep"
    # Nerdctl is inconsistent on the treatment of labels: https://github.com/containerd/nerdctl/issues/2987
    # It could be either a string of key=value, or an object
    [ "$(jq --arg sha "$sha" '. | select(.Labels."org.hadron.plan.sha" | test("^" + $sha + "$"))' <(hadron::query::"$type") ||
         jq --arg sha "$sha" '. | select(.Labels | test("(^|,)org.hadron.plan.sha=" + $sha))?' <(hadron::query::"$type"))" ] &&
    {
      # XXX implement pruning of stopped and created containers here
      # State != running
      if [ "$type" != container ] || \
#        [ "$(jq -rc --arg sha "$sha" '. | select(.Labels | test("(^|,)org.hadron.plan.sha=" + $sha)) | .State' <(hadron::query::"$type"))" == "running" ]; then
#        [ "$(jq -rc --arg sha "$sha" '. | select(.Labels."org.hadron.plan.sha" | test("^" + $sha + "$")) | .State' <(hadron::query::"$type"))" == "running" ]; then
        [ "$(jq -rc --arg sha "$sha" '. | select(.Labels."org.hadron.plan.sha" | test("^" + $sha + "$")) | select(.Status | test("^Up.*"))' <(hadron::query::"$type"))" ]; then
        dc::logger::info " > entity to kept as-is"
        keeplist+=("$name")
      else
        dc::logger::info " > stopped or created container - drop it, recreate it"
        addlist+=("$definition")
      fi
    } || {
      dc::logger::info " > will need to create it"
      addlist+=("$definition")
    }
  done

  # Second, go through all managed objects and delete whatever is not in the keep list
  dc::logger::info "2. looking at the current state to figure out what will need to be garbage collected"
  rmlist=()
  while read -r name; do
    dc::logger::info " > examining $name"
    [ "$name" ] || break
    keep=
    for candidate in "${keeplist[@]}"; do
      if [ "$name" == "$candidate" ]; then
        dc::logger::info " > to be kept"
        keep=true
        break
      fi
    done
    [ "$keep" ] || {
      dc::logger::info " > to be removed"
      rmlist+=("$name")
    }
#  done < <(jq -rc '. | select(.Labels | test("(^|,)org.hadron.plan.sha=.+"))? | .'"$key" <(hadron::query::"$type"))
  done < <(jq -rc '. | select(.Labels."org.hadron.plan.sha" | test(".+")) | .'"$key" <(hadron::query::"$type"))

  dc::logger::info "3. Garbage collecting"
  # Third, do the actual cleanup
  for name in "${rmlist[@]}"; do
    # shellcheck disable=SC2015
    dc::logger::info " ... destroying $name"
    # shellcheck disable=SC2015
    [ "$type" == "network" ] && {
      # Read the resources attached to it and destroy them
      while read -r candidate; do
        [ "$candidate" ] || break
        # We are destroying containers - we will need to refresh state
        _PRIVATE_HADRON_CONTAINER_FORCE_REFRESH=true
        dc::docker::client::container::remove force volumes "$candidate" >/dev/null
      done < <(jq -r '.[].Containers | map(.) | .[] | .Name' <(dc::docker::client::"$type"::inspect json "$name"))

      # We are destroying containers - we will need to refresh state
      _PRIVATE_HADRON_NETWORK_FORCE_REFRESH=true
      # Finally remove the object itself
      dc::docker::client::"$type"::remove "" "$name" >/dev/null
    } || {
      # We are destroying containers - we will need to refresh state
      _PRIVATE_HADRON_CONTAINER_FORCE_REFRESH=true
      # Finally remove the object itself
      dc::docker::client::"$type"::remove force volumes "$name" >/dev/null
    }
  done

  dc::logger::info "4. Creation"
  # Finally, create what needs be
  for definition in "${addlist[@]}"; do
    name="$(jq -rc '.plan.name' - <<<"$definition")"
    dc::logger::info " ... creating $name"
    # XXX just force refresh the right type
    _PRIVATE_HADRON_NETWORK_FORCE_REFRESH=true
    _PRIVATE_HADRON_CONTAINER_FORCE_REFRESH=true
    dc::docker::client::"$type"::"$create" <<<"$definition" >/dev/null
  done
}

hadron::deploy(){
  dc::logger::info "Deployment started"

  dc::logger::info "A. Networks"
  _hadron::deploy::unit network "${HADRON_TARGET_DESIRED_NETWORKS[@]}"

  dc::logger::info "B. Images"
  _hadron::deploy::image

  dc::logger::info "C. Containers"
  _hadron::deploy::unit container "${HADRON_TARGET_DESIRED_CONTAINERS[@]}"

  # Pruning images by default
  dc::docker::client::image::prune "" "" force >/dev/null

  _hadron::plan::reset
}

hadron::login(){
  dc::docker::client::login "$@" >/dev/null
}

###############################################################################
# High level API
###############################################################################

#hadron::info(){
#  dc::docker::client::info json
#}

#hadron::inspect() {
#  local id="${1:-}"

#  dc::argument::check id "$DC_TYPE_STRING" || return

#  dc::docker::client::inspect "json" "$id"
#}

