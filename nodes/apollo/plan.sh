#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

dc::require yj

for module in ./modules/**/*.sh; do
  # shellcheck disable=SC1090
  . "$module"
done

bridge_nick="hadron-bridge"

# Init
hadron::init

# Connect to the node
hadron::connect "$target_user" "$target_address" "${certificate:-}" "${target_port:-}"

# Login to registries
hadron::login "$registry_server" "$secrets_registry_user" "$secrets_registry_pat"

# Create networks
hadron::require::network \
 <(hadron::module::network::defaults "bridge") \
 <(hadron::customize "name=$bridge_nick")

#hadron::require::network \
# <(hadron::module::network::defaults "$vlan_driver") \
# <(hadron::customize \
#  "ipv6=true" \
#  "name=$vlan_nick" \
#  "subnet=[\"$vlan_subnet\", \"$vlan_subnet6\"]" \
#  "gateway=[\"$vlan_gateway\"]" \
#  "ip_range=[\"$vlan_delegation\"]")

# XXX containerd - switching to dhcp
hadron::require::network \
 <(hadron::module::network::defaults "$vlan_driver") \
 <(hadron::customize \
  "ipv6=true" \
  "name=$vlan_nick" \
  "ipam_driver=dhcp" \
)

## Standard
# XXX publish does not work here, because the vlan is FIRST
# Passing multiple networks to a docker run is ill supported, as only the first network gets any option
# A solution could be to instead create, attach, run - but that implies the network is attachable and is much more convoluted
# XXX testing
# moving it to the bridge solely and see if that works
hadron::container \
  <(hadron::module::dns::defaults) \
  <(hadron::env \
    "LOG_LEVEL=$log_level" \
    "DNS_STUFF_MDNS=false" \
  ) \
  <(hadron::customize \
    "ip=$dns_ip" \
    "hostname=dns-$host_name" \
    'network=["'"$bridge_nick"'"]' \
    'publish=["4242:4242/tcp"]' \
  )

#    'network=["'$vlan_nick'", "'"$bridge_nick"'"]' \

hadron::container \
  <(hadron::module::monitor-host::defaults) \
  <(hadron::env \
    "LOG_LEVEL=$log_level" \
  ) \
  <(hadron::customize \
    "hostname=monitor-host-$host_name" \
    'network=["'"$bridge_nick"'"]' \
    'publish=["4243:4242/tcp"]' \
  )

## Custom
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

hadron::container \
  <(hadron::module::roon_endpoint::defaults) \
  <(hadron::env \
    "LOG_LEVEL=$log_level" \
  ) \
  <(hadron::customize \
    "hostname=roon-endpoint-$host_name" \
    'network=["'$vlan_nick'"]' \
  )

extra_command=""
#sep=""
#[ "${mixer:-}" == "" ] || {
#  extra_command+='"--mixer", "'"$mixer"'"'
#  sep=","
#}
[ "$mixer_control" == "" ] || extra_command+='"--alsa-mixer-control", "'"$mixer_control"'"'

hadron::container \
  <(hadron::module::spotify::defaults "$display_enabled") \
  <(hadron::env \
    "LOG_LEVEL=$log_level" \
    "_EXPERIMENTAL_SPOTIFY_CLIENT_ID=${spotify_id:-}" \
    "_EXPERIMENTAL_SPOTIFY_CLIENT_SECRET=${spotify_secret:-}" \
    "MOD_AUDIO_DEVICE=$card" \
    "_EXPERIMENTAL_DISPLAY_ENABLED=$display_enabled" \
    "MOD_MDNS_NAME=$station" \
    "SPOTIFY_MIXER=$mixer" \
  ) \
  <(hadron::customize \
    "hostname=spotify-$host_name" \
    'network=["'"$vlan_nick"'", "'"$bridge_nick"'"]' \
    'dns=["'"$dns_ip"'"]' \
    'command=['"$extra_command"']' \
  )

hadron::deploy
