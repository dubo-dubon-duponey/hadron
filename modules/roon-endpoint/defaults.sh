#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

hadron::module::roon_endpoint::defaults(){
  jq .defaults.[] <(yj -cj <modules/roon-endpoint/defaults.tf)
}
