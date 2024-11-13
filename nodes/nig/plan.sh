#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

# Nightingale is a RPI4 with Amp2
# So:
# - powerful enough for soxr
# - shared alsa volume control

target_user=apo
target_address="nightingale.local"
host_name="nightingale.local"

# Generic config
log_level=info

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
mixer="alsa"
mixer_control="Digital"
display_enabled=false

interpolation=soxr
playback_mode=mono
convolution=yes
convolution_file=/magnetar/user/config/impulse.wav
default_volume="-20.0"

. ./nodes/apollo/plan.sh
