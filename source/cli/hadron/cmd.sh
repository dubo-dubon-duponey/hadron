#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

# shellcheck disable=SC2034
readonly CLI_DESC="fast and simple repalcement for terraform-docker-provider"

dc::commander::initialize
#dc::commander::declare::flag preserve "^$" "do not delete intermediary files" optional p
dc::commander::declare::arg 1 "$DC_TYPE_STRING" "plan" "the plan to run"
dc::commander::boot

[ -e "$DC_ARG_1" ] || {
  dc::error::throw FILESYSTEM "$DC_ARG_1"
  exit
}

# shellcheck source=/dev/null
. "$DC_ARG_1"
