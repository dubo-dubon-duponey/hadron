#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

target_user=apo
target_address="dacodac.local"

# Generic config
log_level=warning
host_name="dacodac.local"

# Network
vlan_nick="hadron-mac-v6"
vlan_parent="eth0"
vlan_driver="macvlan"
vlan_gateway="10.0.4.1"
vlan_sublink="10.0.4.48"
vlan_subnet="10.0.4.0/24"
vlan_subnet6="fd01:dead:bee1::/48"
vlan_size="28"

# DNS
dns_ip="10.0.4.63"

# Registry
registry_server="docker.io"
registry_user="dubodubonduponey"
registry_pat="dckr_pat_8JL7-d424bT0pQqctrWrZgq8MFU"

card="default:CARD=Qutest"
station="Totale Croquette"
mixer=""
display_enabled=true
spotify_id="72349aed826c4f419038414ccb261b2f"
spotify_secret="d49c72f4fa08483cbbe26abd585c2ab5"

. ./nodes/apollo/plan.sh
