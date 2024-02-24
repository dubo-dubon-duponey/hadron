#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

hadron::module::monitor-ui::defaults(){
  jq .defaults.[] <(yj -cj <modules/monitor-ui/defaults.tf)
}
