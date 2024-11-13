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
hadron::containerOLD <(jq \
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
hadron::containerOLD <(jq \
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
convolution="${convolution:+\"type=bind,source=/home/container/config/shairport-sync/impulse.wav,target=/magnetar/user/config/impulse.wav,readonly\"}"
hadron::container \
  <(hadron::module::airplay::defaults) \
  <(hadron::env \
    "LOG_LEVEL=$log_level" \
    "MOD_MDNS_NAME=$station" \
    "MOD_AUDIO_DEVICE=$card" \
    "MOD_AUDIO_MIXER=${mixer_control:-PCM}" \
    "MOD_AUDIO_MODE=${playback_mode:-}" \
    "MOD_AUDIO_VOLUME_DEFAULT=${default_volume:--20.0}" \
    "MOD_AUDIO_VOLUME_IGNORE=${ignore_volume:-}" \
    "SHAIRPORT_GENERAL_INTERPOLATION=${interpolation:-}" ) \
  <(hadron::customize \
    "hostname=airplay-$host_name" \
    'network=["'$vlan_nick'"]' \
    'mount=['$convolution']' \
  )

hadron::containerOLD <(jq \
   --arg hostname "roon-endpoint-$host_name" \
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
' <(hadron::module::roon_endpoint::defaults))

extra_command=""
sep=""
#[ "${mixer:-}" == "" ] || {
#  extra_command+='"--mixer", "'"$mixer"'"'
#  sep=","
#}
[ "$mixer_control" == "" ] || extra_command+="$sep"'"--alsa-mixer-control", "'"$mixer_control"'"'

hadron::containerOLD <(jq \
   --arg hostname "spotify-$host_name" \
   --arg log_level "LOG_LEVEL=$log_level" \
   --argjson network '["'$vlan_nick'"]' \
   --argjson dns '["'"$dns_ip"'"]' \
   \
   --arg mdns_name "MOD_MDNS_NAME=$station" \
   --arg device "MOD_AUDIO_DEVICE=$card" \
   --arg display "_EXPERIMENTAL_DISPLAY_ENABLED=$display_enabled" \
   --arg client_id "_EXPERIMENTAL_SPOTIFY_CLIENT_ID=${spotify_id:-}" \
   --arg client_secret "_EXPERIMENTAL_SPOTIFY_CLIENT_SECRET=${spotify_secret:-}" \
   --arg mixer "SPOTIFY_MIXER=$mixer" \
   --argjson extra_command "[$extra_command]" \
'
.env += [
  $log_level,
  $device,
  $mdns_name,
  $display,
  $client_id,
  $client_secret,
  $mixer
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
