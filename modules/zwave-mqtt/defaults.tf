defaults = {
  name      = "zwave-mqtt"
  image         = "zwavejs/zwave-js-ui"
  privileged    = false
  read_only     = true
  restart       = "always"
  group_add     = [
    "dialout"
  ]
  command       = []
  port          = [8091, 3000]
  cap_add = [
    # "CHOWN","DAC_OVERRIDE",
    # "FSETID", "FOWNER", "MKNOD", "NET_RAW", "SETGID", "SETUID", "SETFCAP", "SETPCAP", "NET_BIND_SERVICE", "SYS_CHROOT", "KILL", "AUDIT_WRITE"
  ]
  devices = [
    "/dev/ttyACM0:/dev/zwave"
  ]


  env = [
  "TZ=America/Los_Angeles",
  "SESSION_SECRET=mysupersecretkey2",
  "ZWAVEJS_EXTERNAL_CONFIG=/usr/src/app/store/.config-db",
  // --health-cmd="wget --no-verbose --spider --no-check-certificate --header "Accept: text/plain" https://localhost:8091/health || exit 1" --health-start-period=30s
  /*
    "ZIGBEE2MQTT_CONFIG_SERIAL_PORT=/dev/ttyUSB0",
    "ZIGBEE2MQTT_CONFIG_HOMEASSISTANT=true",
    "ZIGBEE2MQTT_CONFIG_PERMIT_JOIN=false",
    */
  ]

  mount      = [
    "type=bind,source=/home/container/data/zwave2mqtt,target=/usr/src/app/store",

//    "type=bind,source=/home/container/data/zigbee2mqtt,target=/app/data",
//    "type=bind,source=/run/udev,target=/run/udev"
  ]
}

