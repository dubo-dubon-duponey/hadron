#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

hadron::init

for module in ./modules/**/*.sh; do
  # shellcheck disable=SC1090
  . "$module"
done
# 10.0.4.242

target_user=dmp
target_address="nucomedon.local"

# Generic config
log_level=debug
host_name="nucomedon.local"

# Network
internal_nick="hadron-internal"

bridge_nick="hadron-bridge-v6"
bridge_subnet6="fd01:dead:bee5::/48"

vlan_nick="hadron-mac-v6"
vlan_parent="eno1"
vlan_driver="macvlan"
vlan_gateway="10.0.4.1"
vlan_sublink="10.0.4.96"
vlan_subnet="10.0.4.0/24"
vlan_subnet6="fd01:dead:bee4::/48"
vlan_size="28"

# DNS
dns_serv="10.0.4.5"
dns_thin="10.0.4.6"
dns_peep="10.0.4.7"

# Registry
registry_server="docker.io"
registry_user="dubodubonduponey"
registry_pat="dckr_pat_8JL7-d424bT0pQqctrWrZgq8MFU"




# DNS
mdns_over_dns=false

# Plex
email="o@jsboot.space"
plex_login="Mangled Deutz"
plex_password="LW-kdb4f8Wuhxe.YUcu7fjFyBg@KXK"
domain="sinema.duncan.st"

hadron::connect "$target_user" "$target_address"
hadron::login "$registry_server" "$registry_user" "$registry_pat"

hadron::network <(jq \
     --arg name "$vlan_nick" \
     --arg parent "$vlan_parent" \
     --argjson subnet "[\"$vlan_subnet\", \"$vlan_subnet6\"]" \
     --argjson gateway "[\"$vlan_gateway\"]" \
     --argjson aux_address "[\"link=$vlan_sublink\"]" \
     --argjson ip_range "[\"$vlan_sublink/$vlan_size\"]" \
  '
  . += {
    name: $name,
    ipv6: true,
    parent: $parent,
    subnet: $subnet,
    gateway: $gateway,
    aux_address: $aux_address,
    ip_range: $ip_range
  }
  ' <(hadron::module::network::defaults "$vlan_driver"))

hadron::network <(jq \
     --arg name "$internal_nick" \
  '
  . += {
    name: $name,
    internal: true
  }
  ' <(hadron::module::network::defaults "bridge"))

hadron::network <(jq \
     --arg name "$bridge_nick" \
     --argjson subnet "[\"$bridge_subnet6\"]" \
  '
  . += {
    name: $name,
    ipv6: true,
    subnet: $subnet
  }
  ' <(hadron::module::network::defaults "bridge"))

. ./nodes/nuc/sub_dns.sh
. ./nodes/nuc/sub_media.sh
. ./nodes/nuc/sub_services.sh
. ./nodes/nuc/sub_monitor.sh

hadron::deploy


#hadron::module::vlan "mac-v6" "macvlan" "eth0" "10.0.4.0/24" "fd01:dead:bee4::/48" "10.0.4.1" "link=$sub" "$sub/28"
#hadron::module::dns "mac-v6" "$host_name" "$log_level" "" "$dns_containers"

#hadron::module::dns "mac-v6" "serv-$host_name" "$log_level" "" "$dns_serv"
#hadron::module::dns "mac-v6" "thin-$host_name" "$log_level" "" "$dns_things"
#hadron::module::dns "mac-v6" "peep-$host_name" "$log_level" "" "$dns_people"

