defaults = {
  name          = "home"
  image         = "homeassistant/home-assistant:2024.3"
  privileged    = false
  read_only     = false
  devices       = []
  group_add     = []
  command       = []
  cap_add       = [
    "NET_BIND_SERVICE",
    // Necessary to capture dhcp requests
    "CAP_NET_RAW",
  ]
  env           = [
    "MPLCONFIGDIR=/tmp/config/mpl",
  ]

  tmpfs         = [
    "/tmp:rw,noexec,nosuid,size=1000000"
  ]

  mount        = [
    # rw
    "type=bind,source=/home/container/data/home-assistant,target=/config",
  ]

  volume       = [
    "run-home:/run"
  ]
}
// 8123

// XXX trying to get flair to install - specifying a custom HOME env make it
// that install flow can't find the plugin - so, making /root writable
// (mounting would be better)
