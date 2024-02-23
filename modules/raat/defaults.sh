#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

hadron::module::raat::defaults(){
  jq .defaults.[] <(yj -cj <modules/raat/defaults.tf)
}
