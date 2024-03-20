defaults = {
  name          = "monitor-host"
  image         = "prom/node-exporter:v1.7.0"
  privileged    = false
  read_only     = true
  restart       = "always"
  devices       = []
  group_add     = []
  cap_add       = []
  port          = 4242
  env           = [
    "XDG_DATA_HOME=/magnetar/user/data",
    "XDG_DATA_DIRS=/magnetar/system/data",
    "XDG_CONFIG_HOME=/magnetar/user/config",
    "XDG_CONFIG_DIRS=/magnetar/system/config",
    "XDG_RUNTIME_DIR=/magnetar/runtime",
    "XDG_STATE_HOME=/magnetar/state",
    "XDG_CACHE_HOME=/magnetar/cache",
  ]
  command       = [
    "--web.listen-address=:4242",
    "--log.level=warn",
    "--log.format=logfmt",

    "--path.rootfs=/host",
    "--path.udev.data=/host/run/udev/data",
  ]
  publish = ["4242:4242/tcp"]

  pid           = "host"

  mount        = [
    # ,rslave
    "type=bind,source=/,target=/host,bind-propagation=rslave,readonly"
  ]

}
