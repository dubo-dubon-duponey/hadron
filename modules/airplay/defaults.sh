#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

hadron::module::airplay::defaults(){
  jq .defaults.[] <(yj -cj <modules/airplay/defaults.tf)
}
