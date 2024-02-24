#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

hadron::init

for module in ./modules/**/*.sh; do
  # shellcheck disable=SC1090
  . "$module"
done

target_user=apo
target_address="antimatter.local"

# Generic config
log_level=info
host_name="antimatter.local"

# Network
vlan_nick="hadron-ip-v6"
vlan_parent="wlan0"
vlan_driver="ipvlan"
vlan_gateway="10.0.1.1"
vlan_sublink="10.0.1.112"
vlan_subnet="10.0.1.0/24"
vlan_subnet6="fd01:dead:bee0::/48"
vlan_size="28"

# DNS
dns_ip="10.0.1.127"
dns_stuff_mdns=false

# Registry
registry_server="docker.io"
registry_user="dubodubonduponey"
registry_pat="dckr_pat_8JL7-d424bT0pQqctrWrZgq8MFU"

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
    ip_range: $ip_range,
  }
  ' <(hadron::module::network::defaults "$vlan_driver"))

hadron::container <(jq \
     --arg ip "$dns_ip" \
     --arg hostname "dns-$host_name" \
     --arg log_level "LOG_LEVEL=$log_level" \
     --argjson network '["'"$vlan_nick"'"]' \
     \
     --arg dns_stuff_mdns "DNS_STUFF_MDNS=$dns_stuff_mdns" \
  '
  .env += [
    $log_level,
    $dns_stuff_mdns
  ]
  |
  . += {
    ip: $ip,
    hostname: $hostname,
    network: $network
  }
  ' <(hadron::module::dns::defaults))

hadron::deploy
