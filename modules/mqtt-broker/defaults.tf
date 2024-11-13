defaults = {
  name      = "mqtt-broker"
  image         = "library/eclipse-mosquitto:2.0"
  privileged    = false
  read_only     = true
  restart       = "always"
  devices       = []
  group_add     = []
  command       = [
    "mosquitto", "-c", "/mosquitto-no-auth.conf"
  ]
  port          = [1883, 9001]

  cap_add = [
    "CHOWN","DAC_OVERRIDE", "FSETID", "FOWNER", "MKNOD", "NET_RAW", "SETGID", "SETUID",
  ]

  mount      = [
    "type=bind,source=/home/container/data/mosquitto,target=/mosquitto"
  ]
}
