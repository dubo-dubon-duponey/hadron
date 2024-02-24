#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

for module in ./modules/**/*.sh; do
  # shellcheck disable=SC1090
  . "$module"
done

bridge_nick="hadron-bridge"

hadron::init

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
     --arg name "$bridge_nick" \
  '
  . += {
    name: $name
  }
  ' <(hadron::module::network::defaults "bridge"))

# XXX publish does not work here, because the vlan is FIRST
# Passing multiple networks to a docke run is ill supported, as only the first network gets any option
hadron::container <(jq \
     --arg ip "$dns_ip" \
     --arg hostname "dns-$host_name" \
     --arg log_level "LOG_LEVEL=$log_level" \
     --argjson network '["'"$vlan_nick"'", "'"$bridge_nick"'"]' \
     \
     --arg dns_stuff_mdns "DNS_STUFF_MDNS=false" \
'
.env += [
  $log_level,
  $dns_stuff_mdns
]
|
. += {
  ip: $ip,
  hostname: $hostname,
  network: $network,
  publish: ["4242:4242/tcp"]
}
' <(hadron::module::dns::defaults))

hadron::container <(jq \
   --arg hostname "monitor-host-$host_name" \
   --arg log_level "LOG_LEVEL=$log_level" \
   --argjson network '["'"$bridge_nick"'"]' \
   \
'
.env += [
  $log_level
]
|
. += {
  hostname: $hostname,
  network: $network,
  publish: ["4243:4242/tcp"]
}
' <(hadron::module::monitor-host::defaults))

hadron::container <(jq \
   --arg hostname "airplay-$host_name" \
   --arg log_level "LOG_LEVEL=$log_level" \
   --argjson network '["'$vlan_nick'"]' \
   --argjson dns '["'"$dns_ip"'"]' \
   \
   --arg mdns_name "MOD_MDNS_NAME=$station" \
   --arg device "DEVICE=$card" \
'
.env += [
  $log_level,
  $device,
  $mdns_name
]
|
. += {
  hostname: $hostname,
  network: $network,
  dns: $dns
}
' <(hadron::module::airplay::defaults))

hadron::container <(jq \
   --arg hostname "raat-$host_name" \
   --arg log_level "LOG_LEVEL=$log_level" \
   --argjson network '["'$vlan_nick'"]' \
   --argjson dns '["'"$dns_ip"'"]' \
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
' <(hadron::module::raat::defaults))

extra_command=""
[ "$mixer" == "" ] || extra_command='"--alsa-mixer-control", "'"$mixer"'"'

hadron::container <(jq \
   --arg hostname "spotify-$host_name" \
   --arg log_level "LOG_LEVEL=$log_level" \
   --argjson network '["'$vlan_nick'"]' \
   --argjson dns '["'"$dns_ip"'"]' \
   \
   --arg mdns_name "MOD_MDNS_NAME=$station" \
   --arg device "DEVICE=$card" \
   --arg display "DISPLAY_ENABLED=$display_enabled" \
   --arg client_id "SPOTIFY_CLIENT_ID=${spotify_id:-}" \
   --arg client_secret "SPOTIFY_CLIENT_SECRET=${spotify_secret:-}" \
   --argjson extra_command "[$extra_command]" \
'
.env += [
  $log_level,
  $device,
  $mdns_name,
  $display,
  $client_id,
  $client_secret
]
|
. += {
  hostname: $hostname,
  network: $network,
  dns: $dns
}
|
.command += $extra_command
' <(hadron::module::spotify::defaults "$display_enabled"))

hadron::deploy
