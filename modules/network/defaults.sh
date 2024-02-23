#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

hadron::module::network::defaults(){
  local driver="${1:-macvlan}"
  jq .defaults.[] <(yj -cj <modules/network/"$driver".tf)
}
