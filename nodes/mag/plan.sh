#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

target_user=apo
target_address="magnetar.local"

# Generic config
log_level=warning
host_name="magnetar.local"

# Network
vlan_nick="hadron-mac-v6"
vlan_parent="eth0"
vlan_driver="macvlan"
vlan_gateway="10.0.4.1"
vlan_sublink="10.0.4.80"
vlan_subnet="10.0.4.0/24"
vlan_subnet6="fd01:dead:bee3::/48"
vlan_size="28"

# DNS
dns_ip="10.0.4.95"

# Registry
registry_server="docker.io"
registry_user="dubodubonduponey"
registry_pat="dckr_pat_8JL7-d424bT0pQqctrWrZgq8MFU"

card="default:CARD=Mojo"
station="Magnetar"
mixer=""
display_enabled=false

. ./nodes/apollo/plan.sh
