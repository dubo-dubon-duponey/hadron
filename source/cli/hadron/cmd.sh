#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

# shellcheck disable=SC2034
readonly CLI_DESC="fast and simple replacement for terraform-docker-provider"

dc::commander::initialize
dc::commander::declare::flag "secrets" ".+" "secret file to source from" optional ""
dc::commander::declare::arg 1 "$DC_TYPE_STRING" "plan" "the plan to run"
dc::commander::boot

[ -e "$DC_ARG_1" ] || {
  dc::error::throw FILESYSTEM "$DC_ARG_1"
  exit
}

[ ! "$DC_ARG_SECRETS" ] || . "$DC_ARG_SECRETS"
. "$DC_ARG_1"
