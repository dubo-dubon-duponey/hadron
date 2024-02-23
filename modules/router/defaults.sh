#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

hadron::module::router::defaults(){
  jq .defaults.[] <(yj -cj <modules/router/defaults.tf)
}
