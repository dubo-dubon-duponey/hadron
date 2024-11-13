#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

target_user=apo
target_address="oliphant.local"
host_name="oliphant.local"

# Generic config
log_level=info

# Network
# vlan_nick="hadron-ip-v6"
vlan_nick="hadron-mac-v6"
# vlan_driver="ipvlan"
vlan_driver="macvlan"
vlan_gateway="10.0.0.1"
vlan_subnet="10.0.0.0/24"
vlan_delegation="10.0.0.32/28"
vlan_subnet6="fd00:babe:c0de:0032::/64"

# DNS
# This is the *bridge* ip
dns_ip="10.4.1.42" # 10.0.0.47"

# Registry
registry_server="registry-1.docker.io"

card="default:CARD=sndrpihifiberry"

station="Oliphant"
mixer="alsa"
mixer_control="Digital"

#interpolation=soxr
#playback_mode=mono
#convolution=yes
#convolution_file=/magnetar/user/config/impulse.wav
# default_volume="-20.0"

# XXX deprecated - move elsewhere
display_enabled=false

. ./nodes/apollo/plan.sh
