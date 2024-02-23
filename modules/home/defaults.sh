#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

hadron::module::home::defaults(){
  # XXX somehow not defensive and fails to bring an error up if the file does not exist
  jq .defaults.[] <(yj -cj <modules/home/defaults.tf)
}
