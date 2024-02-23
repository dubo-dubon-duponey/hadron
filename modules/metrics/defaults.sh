#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

hadron::module::metrics::defaults(){
  jq .defaults.[] <(yj -cj <modules/metrics/defaults.tf)
}
