#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

#######################################################################################################################
# Error registration
#######################################################################################################################
dc::internal::error::register DOCKER_NO_CLIENT

dc::internal::error::register DOCKER_WRONG_COMMAND
dc::internal::error::register DOCKER_WRONG_SYNTAX
dc::internal::error::register DOCKER_INVALID_ARGUMENT

#######################################################################################################################
# Public
#######################################################################################################################

# Call this to provide a "docker client"
# This is a bash function or a binary that can interpret docker arguments (could be nerdctl or dockercli, or ssh executing
# some binary on a target host, as long as it recognizes the standard set of docker commands)
dc::docker::client::init(){
  # FIXME might want to verify the client is callable - or consider it an interface that implements
  # - execute
  # - verify
  _DOCKER_CLIENT="$1"
}

#######################################################################################################################
# Docker Generic commands:
# - info
# - inspect
#######################################################################################################################

dc::docker::client::info(){
  local com=(info)

  local format="${1:-}"
  [ "$format" == "" ] || com+=(--format "$format")
  shift || true

  _dc::docker::client::execute "${com[@]}" "$@"
}

dc::docker::client::inspect() {
  local com=(inspect)

  local format="${1:-}"
  [ "$format" == "" ] || com+=(--format "$format")
  shift || true

  _dc::docker::client::execute "${com[@]}" "$@"
}

dc::docker::client::login(){
  local com=(login)
  local registry="${1:-docker.io}"
  local user="$2"
  local password="$3"
  shift
  shift
  shift

  com+=("$registry" --username "$user" --password-stdin)

  # XXX this is not currently portable and is a nasty hack
  # We need a client method that can have stdin
  # dc::ssh::client::execute "$HADRON_TARGET_USER" "$HADRON_TARGET_HOST" "$HADRON_TARGET_IDENTITY" "$HADRON_TARGET_PORT" "docker" "${com[@]}" <<<"$password"
  XXXUBERDIRTY="$password"
  _hadron::underlying  "$HADRON_TARGET_USER" "$HADRON_TARGET_HOST" "$HADRON_TARGET_IDENTITY" "$HADRON_TARGET_PORT" "sudo" "/home/apo/nerdctl" "${com[@]}"
  # <<<"$password"
  # shellcheck disable=SC2034
  XXXUBERDIRTY=
#  _dc::docker::client::execute "${com[@]}" "$@" <<<"$password"
}

#######################################################################################################################
# Private
#######################################################################################################################
_DOCKER_CLIENT=

# A generic docker client executor - mind your syntax, as no checks are applied here
# There is little reason to use direclty - it is private
_dc::docker::client::execute(){
  local ex
  local err

  [ "$_DOCKER_CLIENT" != "" ] || {
    dc::logger::error "No docker client configured. Call docker::client:init to set a working docker client"
    dc::error::throw DOCKER_NO_CLIENT
    return
  }

  # Run it - analyzes further the output if it fails, in order to provide meaningful feedback
  "$_DOCKER_CLIENT" "$@" || {
    ex=$?
    err="$(dc::error::detail::get)"
    # shellcheck disable=SC2015
    printf "%s" "$err" | dc::wrapped::grep -q "docker: '.*' is not a docker command." \
      && {
        dc::error::throw DOCKER_WRONG_COMMAND "$err"
        return
      } || true
    # shellcheck disable=SC2015
    printf "%s" "$err" | dc::wrapped::grep -q "unknown flag" \
      && {
        dc::error::throw DOCKER_WRONG_SYNTAX "$err"
        return
      } || true
    # shellcheck disable=SC2015
    printf "%s" "$err" | dc::wrapped::grep -q "invalid argument" \
      && {
        dc::error::throw DOCKER_INVALID_ARGUMENT "$err"
        return
      } || true

    dc::error::throw "$ex" "$err" passthrough
    return
  }
}
