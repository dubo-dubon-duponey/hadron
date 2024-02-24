#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

# Working to some extent - configuration needs tweaks
hadron::container <(jq \
     --arg ip "10.0.4.10" \
     --arg hostname "router-$host_name" \
     --arg log_level "LOG_LEVEL=$log_level" \
     --argjson network '["'"$vlan_nick"'", "'"$bridge_nick"'", "'"$internal_nick"'"]' \
     --argjson dns '["'"$dns_serv"'"]' \
     \
  '
  .env += [
    $log_level
  ]
  |
  . += {
    ip: $ip,
    hostname: $hostname,
    network: $network,
    dns: $dns,

    publish: ["80:80/tcp", "443:443"]
  }
  ' <(hadron::module::router::defaults))


# Untested
hadron::container <(jq \
     --arg hostname "share-$host_name" \
     --arg log_level "LOG_LEVEL=$log_level" \
     --argjson network '["'"$vlan_nick"'"]' \
     \
     --arg users 'USERS=dmp anne apostasie' \
     --arg passwords 'PASSWORDS=m8kXGjm8jWzHRRM6iwvBjNPpdks4pl FfGbDYQ8kh3_o@grUPKeygh7oN897u XgcED3bYtKmXsBR9u2iJJ!P-vtmJUE' \
     \
  '
  .env += [
    $log_level,
    $users,
    $passwords,
    "MOD_MDNS_ENABLED=true",
    "MOD_MDNS_HOST=samba",
    "MOD_MDNS_NAME=So Danco"
  ]
  |
  . += {
    hostname: $hostname,
    network: $network
  }
  ' <(hadron::module::share::defaults))

# Works, but has lost the lock and many of the lights in the MQTT snaff
hadron::container <(jq \
     --arg hostname "home-$host_name" \
     --arg log_level "LOG_LEVEL=$log_level" \
     --argjson network '["'"$vlan_nick"'", "'"$bridge_nick"'"]' \
     --argjson dns '["'"$dns_serv"'"]' \
     \
  '
  .env += [
    $log_level
  ]
  |
  . += {
    hostname: $hostname,
    network: $network,
    dns: $dns
  }
  ' <(hadron::module::home::defaults))


