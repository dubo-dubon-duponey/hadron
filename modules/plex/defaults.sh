#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

hadron::module::plex::defaults(){
  jq .defaults.[] <(yj -cj <modules/plex/defaults.tf)
}
