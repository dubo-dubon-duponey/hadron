#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

hadron::module::share::defaults(){
  jq .defaults.[] <(yj -cj <modules/share/defaults.tf)
}
