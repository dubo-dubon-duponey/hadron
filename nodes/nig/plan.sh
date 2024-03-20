#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

target_user=apo
target_address="nightingale.local"
host_name="nightingale.local"

# Generic config
log_level=warning

# Network
vlan_nick="hadron-mac-v6"
vlan_driver="macvlan"
vlan_gateway="10.0.0.1"
vlan_subnet="10.0.0.0/24"
vlan_delegation="10.0.0.64/28"
vlan_subnet6="fd00:babe:c0de:0064::/64"

# DNS
dns_ip="10.0.0.79"

# Registry
registry_server="docker.io"
registry_user="dubodubonduponey"
registry_pat="dckr_pat_8JL7-d424bT0pQqctrWrZgq8MFU"

card="default:CARD=sndrpihifiberry"
station="Nightingale"
mixer="Digital"
display_enabled=false

. ./nodes/apollo/plan.sh
