#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

# Right now, this is meant only for local containers
hadron::containerOLD <(jq \
     --arg ip "$dns_serv" \
     --arg name "dns-serv" \
     --arg hostname "dns-serv-$host_name" \
     --arg log_level "LOG_LEVEL=$log_level" \
     --argjson network '["'"$vlan_nick"'", "'"$internal_nick"'"]' \
     \
     --arg mdns_over_dns "DNS_STUFF_MDNS=true" \
  '
  .env += [
    $log_level,
    $mdns_over_dns
  ]
  |
  . += {
    ip: $ip,
    name: $name,
    hostname: $hostname,
    network: $network
  }
  ' <(hadron::module::dns::defaults))

# For all the things on the LAN - must be exposed, on a fixed ip
hadron::containerOLD <(jq \
     --arg ip "$dns_thin" \
     --arg name "dns-thin" \
     --arg hostname "dns-thin-$host_name" \
     --arg log_level "LOG_LEVEL=$log_level" \
     --argjson network '["'"$vlan_nick"'", "'"$internal_nick"'"]' \
     \
     --arg mdns_over_dns "DNS_STUFF_MDNS=false" \
  '
  .env += [
    $log_level,
    $mdns_over_dns
  ]
  |
  . += {
    ip: $ip,
    name: $name,
    hostname: $hostname,
    network: $network
  }
  ' <(hadron::module::dns::defaults))

# For normal people - must be exposed, on a fixed ip - could be host or bridging into host
hadron::containerOLD <(jq \
     --arg ip "$dns_peep" \
     --arg name "dns-peep" \
     --arg hostname "dns-peep-$host_name" \
     --arg log_level "LOG_LEVEL=$log_level" \
     --argjson network '["'"$vlan_nick"'", "'"$internal_nick"'"]' \
     \
     --arg mdns_over_dns "DNS_STUFF_MDNS=true" \
  '
  .env += [
    $log_level,
    $mdns_over_dns
  ]
  |
  . += {
    ip: $ip,
    name: $name,
    hostname: $hostname,
    network: $network
  }
  ' <(hadron::module::dns::defaults))



