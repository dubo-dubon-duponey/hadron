#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

# Working to some extent - configuration needs tweaks
hadron::containerOLD <(jq \
     --arg ip "10.0.0.9" \
     --arg hostname "router-$host_name" \
     --arg log_level "LOG_LEVEL=$log_level" \
     --argjson network '["'"$vlan_nick"'", "'"$internal_nick"'"]' \
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

# , "/dev/bus/usb/001/005"
# XXX Probably does not need dns
#     --argjson devices '["/dev/usb/lp0", "/dev/bus/usb/001/006"]' \
hadron::containerOLD <(jq \
     --arg hostname "share-$host_name" \
     --arg log_level "LOG_LEVEL=$log_level" \
     --argjson network '["'"$vlan_nick"'"]' \
     --argjson dns '["'"$dns_serv"'"]' \
     \
     --arg users 'USERS='"$samba_users" \
     --arg passwords 'PASSWORDS='"$samba_passwords" \
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
    network: $network,
    dns: $dns
  }
  ' <(hadron::module::share::defaults))

# Print
hadron::containerOLD <(jq \
     --arg hostname "print-$host_name" \
     --arg log_level "LOG_LEVEL=$log_level" \
     --argjson network '["'"$vlan_nick"'"]' \
     \
  '
  .env += [
    $log_level
  ]
  |
  . += {
    hostname: $hostname,
    network: $network,
  }
  ' <(hadron::module::print::defaults))

# Works, but has lost the lock and many of the lights in the MQTT snaff
hadron::containerOLD <(jq \
     --arg hostname "home-$host_name" \
     --arg log_level "LOG_LEVEL=$log_level" \
     --argjson network '["'"$vlan_nick"'", "'"$internal_nick"'"]' \
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


