#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

hadron::module::dns::defaults(){
  jq .defaults.[] <(yj -cj <modules/dns/defaults.tf)
}

