#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

hadron::module::roon::defaults(){
  jq .defaults.[] <(yj -cj <modules/roon/defaults.tf)
}
