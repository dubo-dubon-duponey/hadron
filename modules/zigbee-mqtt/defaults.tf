defaults = {
  name      = "zigbee-mqtt"
  image         = "koenkk/zigbee2mqtt"
  privileged    = false
  read_only     = true
  restart       = "always"
  group_add     = [
    "dialout"
  ]
  command       = []
  port          = [8080]
  cap_add = [
    # "CHOWN","DAC_OVERRIDE",
    # "FSETID", "FOWNER", "MKNOD", "NET_RAW", "SETGID", "SETUID", "SETFCAP", "SETPCAP", "NET_BIND_SERVICE", "SYS_CHROOT", "KILL", "AUDIT_WRITE"
  ]
  devices = [
    "/dev/ttyUSB0"
  ]
  env = [
    "ZIGBEE2MQTT_CONFIG_SERIAL_PORT=/dev/ttyUSB0",
    "ZIGBEE2MQTT_CONFIG_HOMEASSISTANT=true",
    "ZIGBEE2MQTT_CONFIG_PERMIT_JOIN=false",
  ]

  mount      = [
    "type=bind,source=/home/container/data/zigbee2mqtt,target=/app/data",
    "type=bind,source=/run/udev,target=/run/udev"
  ]
}

