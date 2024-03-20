defaults = {
  name      = "ble-mqtt"
  image         = "dubodubonduponey/theengs"
  privileged    = false
  read_only     = true
  restart       = "always" // no

  group_add     = [
  ]
  command       = [
    "--identities", "00:C5:85:E9:7B:AE", "LhcVnJKqgDhcGRPzxI4FpQ=="
  ]
  port          = []
  cap_add = [
    # "CHOWN","DAC_OVERRIDE",
    # "FSETID", "FOWNER", "MKNOD", "NET_RAW", "SETGID", "SETUID", "SETFCAP", "SETPCAP", "NET_BIND_SERVICE", "SYS_CHROOT", "KILL", "AUDIT_WRITE"
  ]
  devices = [
  ]

  env = [
    "PUBLISH_ALL=true",
    "TIME_BETWEEN=60",
    "SCAN_TIME=60",
    "DISCOVERY_TOPIC=homeassistant/sensor",
    "DISCOVERY_FILTER=[IBEACON,GAEN,MS-CDP]",
    "SCANNING_MODE=active",
    "ADAPTER=hci0",
    "MQTT_PUB_TOPIC=home/TheengsGateway/BTtoMQTT",
    "MQTT_SUB_TOPIC=home/TheengsGateway/commands"
  // --health-cmd="wget --no-verbose --spider --no-check-certificate --header "Accept: text/plain" https://localhost:8091/health || exit 1" --health-start-period=30s
  /*
    "ZIGBEE2MQTT_CONFIG_SERIAL_PORT=/dev/ttyUSB0",
    "ZIGBEE2MQTT_CONFIG_HOMEASSISTANT=true",
    "ZIGBEE2MQTT_CONFIG_PERMIT_JOIN=false",
    */
  ]

  mount      = [
    "type=bind,source=/var/run/dbus,target=/var/run/dbus",
    "type=bind,source=/home/container/config/theengs,target=/root",

//    "type=bind,source=/home/container/data/zigbee2mqtt,target=/app/data",
//    "type=bind,source=/run/udev,target=/run/udev"
  ]
}

