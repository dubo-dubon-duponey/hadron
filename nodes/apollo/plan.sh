#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

for module in ./modules/**/*.sh; do
  # shellcheck disable=SC1090
  . "$module"
done

bridge_nick="hadron-bridge"

# Init
hadron::init

# Connect to the node
hadron::connect "$target_user" "$target_address"

# Login to registries
hadron::login "$registry_server" "$registry_user" "$registry_pat"

# Create networks
hadron::network \
 <(hadron::module::network::defaults "$vlan_driver") \
 <(hadron::customize \
  "ipv6=true" \
  "name=$vlan_nick" \
  "subnet=[\"$vlan_subnet\", \"$vlan_subnet6\"]" \
  "gateway=[\"$vlan_gateway\"]" \
  "ip_range=[\"$vlan_delegation\"]")

hadron::network \
 <(hadron::module::network::defaults "bridge") \
 <(hadron::customize "name=$bridge_nick")

# Deploy the DNS service
hadron::container <(jq \
     --arg ip "$dns_ip" \
     --arg hostname "dns-$host_name" \
     --arg log_level "LOG_LEVEL=$log_level" \
     --argjson network '["'"$vlan_nick"'", "'"$bridge_nick"'"]' \
'
.env += [
  $log_level
]
|
. += {
  ip: $ip,
  hostname: $hostname,
  network: $network
}
' <(hadron::module::dns::defaults))

# Deploy the monitoring service
hadron::container <(jq \
   --arg hostname "monitor-host-$host_name" \
   --arg log_level "LOG_LEVEL=$log_level" \
   --argjson network '["'"$bridge_nick"'"]' \
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

# Deploy airplay - no DNS needed
hadron::container <(jq \
   --arg hostname "airplay-$host_name" \
   --arg log_level "LOG_LEVEL=$log_level" \
   --argjson network '["'$vlan_nick'"]' \
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
  network: $network
}
' <(hadron::module::airplay::defaults))

hadron::container <(jq \
   --arg hostname "raat-$host_name" \
   --arg log_level "LOG_LEVEL=$log_level" \
   --argjson network '["'$vlan_nick'"]' \
   \
'
.env += [
  $log_level
]
|
. += {
  hostname: $hostname,
  network: $network
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
