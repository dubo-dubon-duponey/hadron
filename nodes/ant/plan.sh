#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

hadron::init

for module in ./modules/**/*.sh; do
  # shellcheck disable=SC1090
  . "$module"
done

target_user=apo
target_address="antimatter.local"
host_name="antimatter.local"

# Generic config
log_level=info

# Network
vlan_nick="hadron-ip-v6"
vlan_driver="ipvlan"
vlan_gateway="10.0.2.1"
vlan_subnet="10.0.2.0/24"
vlan_delegation="10.0.2.112/28"
vlan_subnet6="fd00:babe:c0de:2112::/64"

# DNS
dns_ip="10.0.2.127"

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
   --arg hostname "mqtt-broker-$host_name" \
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
  publish: ["9001:9001/tcp", "1883:1883/tcp"]
}
' <(hadron::module::mqtt-broker::defaults))

hadron::containerOLD <(jq \
   --arg hostname "zigbee-mqtt-$host_name" \
   --arg log_level "LOG_LEVEL=$log_level" \
   --argjson network '["'"$bridge_nick"'"]' \
   --arg server "ZIGBEE2MQTT_CONFIG_MQTT_SERVER=mqtt://mqtt-broker" \
   \
'
.env += [
  $log_level,
  $server,
  "ZIGBEE2MQTT_CONFIG_PERMIT_JOIN=true"
]
|
. += {
  hostname: $hostname,
  network: $network,
  publish: ["8080:8080/tcp"]
}
' <(hadron::module::zigbee-mqtt::defaults))

hadron::deploy
