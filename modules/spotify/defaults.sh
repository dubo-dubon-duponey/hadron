#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

hadron::module::spotify::defaults(){
  local withtty="${1:-}"

  if [ "$withtty" == true ]; then
    jq -s '.[0] + .[1]' <(jq .defaults.[] <(yj -cj <modules/spotify/defaults.tf)) <(jq .defaults.[] <(yj -cj <modules/spotify/with_tty.tf))
  else
    jq .defaults.[] <(yj -cj <modules/spotify/defaults.tf)
  fi
}
