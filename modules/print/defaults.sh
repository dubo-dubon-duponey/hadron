#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

hadron::module::print::defaults(){
  jq .defaults.[] <(yj -cj <modules/print/defaults.tf)
}
