#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

hadron::init

for module in ./modules/**/*.sh; do
  # shellcheck disable=SC1090
  . "$module"
done
# 10.0.0.242

target_user=dmp
target_address="nucomedon.local"
host_name="nucomedon.local"

# Generic config
log_level=debug

# Network
internal_nick="hadron-internal"

bridge_nick="hadron-bridge-v6"
bridge_subnet6="fd00:babe:b00b:cafe::/64"

vlan_nick="hadron-mac-v6"
vlan_parent="eno1"
vlan_driver="macvlan"
vlan_gateway="10.0.0.1"
vlan_subnet="10.0.0.0/24"
vlan_delegation="10.0.0.96/28"
# https://blog.oddbit.com/post/2018-03-12-using-docker-macvlan-networks/
# ip link del dubo-shim 2>/dev/null
# ip link add dubo-shim link eno1 type macvlan  mode bridge
# ip addr add 10.0.0.111/32 dev dubo-shim
# ip link set dubo-shim up
# sudo ip route add 10.0.0.5/32 dev dubo-shim
#### ip route add 10.0.0.96/28 dev dubo-shim
aux_address="link=10.0.0.111"
vlan_subnet6="fd00:babe:c0de:0096::/64"

# DNS
dns_serv="10.0.0.5"
dns_peep="10.0.0.6"
dns_thin="10.0.0.7"

# Registry
registry_server="registry-1.docker.io"

registry_server2="ghcr.io"


# DNS
mdns_over_dns=false

# Plex
email="o@jsboot.space"
plex_login="Mangled Deutz"
plex_password="LW-kdb4f8Wuhxe.YUcu7fjFyBg@KXK"
domain="sinema.duncan.st"

hadron::connect "$target_user" "$target_address"

hadron::login "$registry_server" "$secrets_registry_user" "$secrets_registry_pat"
hadron::login "$registry_server2" "$secrets_registry_user_ghcr" "$secrets_registry_pat_ghcr"


hadron::require::network \
 <(hadron::module::network::defaults "$vlan_driver") \
 <(hadron::customize \
  "ipv6=true" \
  "name=$vlan_nick" \
  "subnet=[\"$vlan_subnet\", \"$vlan_subnet6\"]" \
  "gateway=[\"$vlan_gateway\"]" \
  "ip_range=[\"$vlan_delegation\"]" \
  "aux_address=[\"$aux_address\"]" \
  "parent=$vlan_parent")

hadron::require::network \
 <(hadron::module::network::defaults "bridge") \
 <(hadron::customize \
  "name=$internal_nick" \
  "internal=true" \
 )

hadron::require::network \
 <(hadron::module::network::defaults "bridge") \
 <(hadron::customize \
  "name=$bridge_nick" \
  "ipv6=true" \
  "subnet=[\"$bridge_subnet6\"]" \
 )

. ./nodes/nuc/sub_dns.sh
. ./nodes/nuc/sub_media.sh
. ./nodes/nuc/sub_services.sh
. ./nodes/nuc/sub_monitor.sh

hadron::deploy
