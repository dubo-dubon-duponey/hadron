#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

hadron::containerOLD <(jq \
     --arg hostname "roon-$host_name" \
     --arg log_level "LOG_LEVEL=$log_level" \
     --arg dis "MOD_HTTP_ENABLED=false" \
     --argjson network '["'"$vlan_nick"'", "'"$internal_nick"'"]' \
     --argjson dns '["'"$dns_serv"'"]' \
     \
  '
  .env += [
    $log_level,
    $dis
  ]
  |
  . += {
    hostname: $hostname,
    network: $network,
    dns: $dns
  }
  ' <(hadron::module::roon::defaults))

hadron::containerOLD <(jq \
     --arg hostname "plex-$host_name" \
     --arg log_level "LOG_LEVEL=$log_level" \
     --argjson network '["'"$vlan_nick"'"]' \
     --argjson dns '["'"$dns_serv"'"]' \
     \
     --arg email "DBDB_MAIL=$email" \
     --arg plex_login "DBDB_LOGIN=$plex_login" \
     --arg plex_password "DBDB_PASSWORD=$plex_password" \
     --arg domain "DBDB_SERVER_NAME=$domain" \
  '
  .env += [
    $log_level,
    $plex_login,
    $plex_password,
    $email,
    $domain,
    "DBDB_ADVERTISE_IP="
  ]
  |
  . += {
    hostname: $hostname,
    network: $network,
    dns: $dns
  }
  ' <(hadron::module::plex::defaults))
