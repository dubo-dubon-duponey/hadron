#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

target_user=apo
target_address="dacodac.local"
host_name="dacodac.local"

# Generic config
log_level=warn

# Network
vlan_nick="hadron-mac-v6"
vlan_driver="macvlan"
vlan_gateway="10.0.0.1"
vlan_subnet="10.0.0.0/24"
vlan_delegation="10.0.0.48/28"
vlan_subnet6="fd00:babe:c0de:0048::/64"

# DNS
dns_ip="10.0.0.63"

# Registry
registry_server="registry-1.docker.io"

# USB out
#card="default:CARD=Qutest"
# Optical out
card="hw:CARD=sndrpihifiberry,DEV=0"

station="Totale Croquette"
mixer=""
mixer_control=""

ignore_volume=yes

spotify_id="72349aed826c4f419038414ccb261b2f"
spotify_secret="d49c72f4fa08483cbbe26abd585c2ab5"

# XXX deprecated - move elsewhere
display_enabled=true

. ./nodes/apollo/plan.sh
