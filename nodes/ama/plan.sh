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
registry_server="registry-1.docker.io"
bridge_nick="hadron-bridge"

hadron::connect "$target_user" "$target_address"
hadron::login "$registry_server" "$secrets_registry_user" "$secrets_registry_pat"

hadron::require::network \
 <(hadron::module::network::defaults "bridge") \
 <(hadron::customize "name=$bridge_nick")

hadron::require::network \
 <(hadron::module::network::defaults "$vlan_driver") \
 <(hadron::customize \
  "ipv6=true" \
  "name=$vlan_nick" \
  "subnet=[\"$vlan_subnet\", \"$vlan_subnet6\"]" \
  "gateway=[\"$vlan_gateway\"]" \
  "ip_range=[\"$vlan_delegation\"]")

## Standard
# XXX publish does not work here, because the vlan is FIRST
# Passing multiple networks to a docker run is ill supported, as only the first network gets any option
# A solution could be to instead create, attach, run - but that implies the network is attachable and is much more convoluted
hadron::container \
  <(hadron::module::dns::defaults) \
  <(hadron::env \
    "LOG_LEVEL=$log_level" \
    "DNS_STUFF_MDNS=false" \
  ) \
  <(hadron::customize \
    "ip=$dns_ip" \
    "hostname=dns-$host_name" \
    'network=["'$vlan_nick'", "'"$bridge_nick"'"]' \
    'publish=["4242:4242/tcp"]' \
  )

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
hadron::container \
  <(hadron::module::zwave-mqtt::defaults) \
  <(hadron::env \
    "LOG_LEVEL=$log_level" \
  ) \
  <(hadron::customize \
    "hostname=zwave-mqtt-$host_name" \
    'network=["'"$bridge_nick"'"]' \
    'publish=["8091:8091/tcp", "3000:3000/tcp"]' \
  )

# XXX there is some announce mechanism, though it might not be particularly useful
hadron::container \
  <(hadron::module::ble-mqtt::defaults) \
  <(hadron::env \
    "LOG_LEVEL=$(printf "%s" "$log_level" | tr '[:lower:]' '[:upper:]')" \
    "MQTT_HOST=10.0.1.200" \
    "DISCOVERY_DEVICE_NAME=BLEGateway" \
  ) \
  <(hadron::customize \
    "hostname=ble-mqtt-$host_name" \
    'network=["'"$vlan_nick"'"]' \
    'publish=["8091:8091/tcp", "3000:3000/tcp"]' \
  )

hadron::deploy

