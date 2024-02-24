#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

hadron::module::monitor-db::defaults(){
  jq .defaults.[] <(yj -cj <modules/monitor-db/defaults.tf)
}
