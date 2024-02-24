#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

# Grafana needs network to retrieve dashboards from their website...
# This is a shame that it is not doing that purely client side...
hadron::container <(jq \
     --arg hostname "monitor-ui-$host_name" \
     --arg log_level "LOG_LEVEL=$log_level" \
     --argjson network '["'"$internal_nick"'", "'"$bridge_nick"'"]' \
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
  ' <(hadron::module::monitor-ui::defaults))

# Prometheus needs network to scrape /metrics from other hosts...
# Alternatively, we could expose an internal forward proxy that it could scrape, but that seems like a lot of mapping
hadron::container <(jq \
     --arg hostname "monitor-db-$host_name" \
     --arg log_level "LOG_LEVEL=$log_level" \
     --argjson network '["'"$internal_nick"'", "'"$bridge_nick"'"]' \
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
  ' <(hadron::module::monitor-db::defaults))

hadron::container <(jq \
     --arg hostname "monitor-unifi-$host_name" \
     --arg log_level "LOG_LEVEL=$log_level" \
     --argjson network '["'"$internal_nick"'", "'"$bridge_nick"'"]' \
     \
  '
  .env += [
    $log_level,
    "UP_POLLER_DEBUG=false",
    "UP_POLLER_QUIET=true",
    "UP_UNIFI_DEFAULT_URL=https://controller.farcloser.world",
    "UP_UNIFI_DEFAULT_USER=unifipoller",
    "UP_UNIFI_DEFAULT_PASS=zz3rhhYLhnDTEuD2kDN7",
    "UP_UNIFI_DEFAULT_SAVE_SITES=true",
    "UP_UNIFI_DEFAULT_SAVE_DPI=true",
    "UP_UNIFI_DEFAULT_VERIFY_SSL=true",
    "UP_PROMETHEUS_DISABLE=false",
    "UP_PROMETHEUS_HTTP_LISTEN=:4242",
    "UP_INFLUXDB_DISABLE=true"
  ]
  |
  . += {
    hostname: $hostname,
    network: $network
  }
  ' <(hadron::module::monitor-unifi::defaults))

hadron::container <(jq \
     --arg hostname "monitor-host-$host_name" \
     --arg log_level "LOG_LEVEL=$log_level" \
     --argjson network '["'"$internal_nick"'"]' \
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
  ' <(hadron::module::monitor-host::defaults))

hadron::container <(jq \
     --arg hostname "monitor-container-$host_name" \
     --arg log_level "LOG_LEVEL=$log_level" \
     --argjson network '["'"$internal_nick"'"]' \
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
  ' <(hadron::module::monitor-container::defaults))

