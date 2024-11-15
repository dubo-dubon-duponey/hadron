#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

target_user=apo
target_address="magnetar.local"
host_name="magnetar.local"

# Generic config
log_level=info

# Network
vlan_nick="hadron-mac-v6"
vlan_driver="macvlan"
vlan_gateway="10.0.0.1"
vlan_subnet="10.0.0.0/24"
vlan_delegation="10.0.0.80/28"
vlan_subnet6="fd00:babe:c0de:0080::/64"

# DNS
dns_ip="10.0.0.95"

# Registry
registry_server="registry-1.docker.io"

card="default:CARD=Mojo"

station="Magnetar"
mixer=""
mixer_control=""

ignore_volume=yes

# XXX deprecated - move elsewhere
display_enabled=false

ignore_volume=yes

. ./nodes/apollo/plan.sh
