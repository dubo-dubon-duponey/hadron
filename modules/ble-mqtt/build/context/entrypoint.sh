#!/bin/bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

. /boot/bin/activate

CONFIG="$HOME/theengsgw.conf"

create_config(){
  # Exit if MQTT host not specified
  [ "${MQTT_HOST:-}" ] || {
    echo "MQTT Host not defined, exiting"
    exit 1
  }

  [ ! "${MQTT_USERNAME:-}" ] || [ "${MQTT_PASSWORD:-}" ] || {
    echo "MQTT_USERNAME specified without MQTT_PASSWORD"
    exit 1
  }

  ### Syntax checks - START
  if [ "${MQTT_PORT:-}" ]; then
    if ! [[ $MQTT_PORT =~ ^[0-9]+$ ]]; then
      echo "WARNING : Wrong value for MQTT_PORT environment variable, will use default - 1883"
      MQTT_PORT=1883
    fi
  fi

  if [ "${PUBLISH_ALL:-}" ]; then
    if ! [[ $PUBLISH_ALL =~ (true|false) ]]; then
      echo "WARNING : Wrong value for PUBLISH_ALL environment variable, will use default - true"
      PUBLISH_ALL=true
    fi
  fi

  if [ "${SCAN_TIME:-}" ]; then
    if ! [[ $SCAN_TIME =~ ^[0-9]+$ ]]; then
      echo "WARNING : Wrong value for SCAN_TIME environment variable, will use default - 60"
      SCAN_TIME=60
    fi
  fi

  if [ "${TIME_BETWEEN:-}" ]; then
    if ! [[ $TIME_BETWEEN =~ ^[0-9]+$ ]]; then
      echo "WARNING : Wrong value for TIME_BETWEEN environment variable, will use default - 60"
      TIME_BETWEEN=60
    fi
  fi

  if [ "${LOG_LEVEL:-}" ]; then
    if ! [[ $LOG_LEVEL =~ (DEBUG|INFO|WARNING|ERROR|CRITICAL) ]]; then
      echo "WARNING : Wrong value for LOG_LEVEL environment variable, will use default - DEBUG"
      LOG_LEVEL=DEBUG
    fi
  fi

  if [ "${DISCOVERY:-}" ]; then
    if ! [[ $DISCOVERY =~ (true|false) ]]; then
      echo "WARNING : Wrong value for DISCOVERY environment variable, will use default - true"
      DISCOVERY=true
    fi
  fi

  if [ "${PASSIVE_SCAN:-}" ]; then
    # Deprecation warning, this was written before 0.5.0 was released , will use SCANNIN_MODE in future
    echo "PASSIVE_SCAN : Deprecated environment variable, this variable will be removed in future versions, please use SCANNING_MODE=active|passive"

    if [[ $PASSIVE_SCAN == true ]]; then
      echo "Enabling passive scanning mode"
      SCANNING_MODE="passive"
    elif [[ $PASSIVE_SCAN == false ]]; then
      echo "Disabling passive scanning mode"
      SCANNING_MODE="active"
    else
      echo "Incorrect value for PASSIVE_SCAN environment variable, will use default - active"
    fi
  fi

  if [ "${ADAPTER:-}" ]; then
    if ! [ -d /sys/class/bluetooth/$ADAPTER ]; then
      echo "WARNING : Adapter name $ADAPTER might not exist. Will accept the value but if you notice issues , please change it"
    fi
  fi

  if [ "${SCANNING_MODE:-}" ]; then
    if ! [[ $SCANNING_MODE =~ (active|passive) ]]; then
      echo "WARNING : Wrong value for SCANNING_MODE, must be one of: active, passive. Will use default - active"
      SCANNING_MODE=active
    fi
  fi

  echo "Creating config at $CONFIG ..."
  cat <<EOF> "$CONFIG"
{
    "host": "${MQTT_HOST:-}",
    "pass": "${MQTT_PASSWORD:-}",
    "user": "${MQTT_USERNAME:-}",
    "port": ${MQTT_PORT:-1883},
    "publish_topic": "${MQTT_PUB_TOPIC:-home/TheengsGateway/BTtoMQTT}",
    "subscribe_topic": "${MQTT_SUB_TOPIC:-home/TheengsGateway/commands}",
    "publish_all": ${PUBLISH_ALL:-true},
    "ble_scan_time": ${SCAN_TIME:-60},
    "ble_time_between_scans": ${TIME_BETWEEN:-60},
    "log_level": "${LOG_LEVEL:-DEBUG}",
    "discovery": ${DISCOVERY:-true},
    "discovery_topic": "${DISCOVERY_TOPIC:-homeassistant/sensor}",
    "discovery_device_name": "${DISCOVERY_DEVICE_NAME:-TheengsGateway}",
    "discovery_filter": "${DISCOVERY_FILTER:-[IBEACON,GAEN,MS-CDP]}",
    "scanning_mode": "${SCANNING_MODE:-active}",
    "adapter": "${ADAPTER:-hci0}"
}
EOF

}

[ -e "$CONFIG" ] || create_config

cat "$CONFIG"

cd "$VIRTUAL_ENV"

python3 -m TheengsGateway "$@"
