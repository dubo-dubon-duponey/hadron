#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

hadron::init

for module in ./modules/**/*.sh; do
  # shellcheck disable=SC1090
  . "$module"
done

target_user=apo
target_address="amaterasu.local"
host_name="amaterasu.local"

# Generic config
log_level=info

# Network
vlan_nick="hadron-ip-v6"
vlan_driver="ipvlan"
vlan_gateway="10.0.2.1"
vlan_subnet="10.0.2.0/24"
vlan_delegation="10.0.2.128/28"
vlan_subnet6="fd00:babe:c0de:2128::/64"

# DNS
dns_ip="10.0.2.143"

# Registry
registry_server="docker.io"
registry_user="dubodubonduponey"
registry_pat="dckr_pat_8JL7-d424bT0pQqctrWrZgq8MFU"

bridge_nick="hadron-bridge"

hadron::connect "$target_user" "$target_address"
hadron::login "$registry_server" "$registry_user" "$registry_pat"

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

# XXX publish does not work here, because the vlan is FIRST
# Passing multiple networks to a docker run is ill supported, as only the first network gets any option
hadron::containerOLD <(jq \
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

hadron::containerOLD <(jq \
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

hadron::containerOLD <(jq \
   --arg hostname "zwave-mqtt-$host_name" \
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
  publish: ["8091:8091/tcp", "3000:3000/tcp"]
}
' <(hadron::module::zwave-mqtt::defaults))

#

# XXX there is some announce mechanism, though it might not be particularly useful
hadron::containerOLD <(jq \
   --arg hostname "ble-mqtt-$host_name" \
   --arg log_level "LOG_LEVEL=$(printf "%s" "$log_level" | tr '[:lower:]' '[:upper:]')" \
   --argjson network '["'"$vlan_nick"'"]' \
   \
   --arg mqtt_host "MQTT_HOST=10.0.1.200" \
   --arg device_name "DISCOVERY_DEVICE_NAME=BLEGateway" \
'
.env += [
  $log_level,
  $device_name,
  $mqtt_host
]
|
. += {
  hostname: $hostname,
  network: $network,
  publish: ["8091:8091/tcp", "3000:3000/tcp"]
}
' <(hadron::module::ble-mqtt::defaults))

hadron::deploy

