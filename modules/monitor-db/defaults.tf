defaults = {
  name          = "monitor-db"
  image         = "prom/prometheus:v2.50.0"
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

    "--config.file=/etc/prometheus/prometheus.yml"
  ]

  volume       = [
    # data
    "data-prometheus:/prometheus"
  ]

  mount        = [
    # ro
    "type=bind,source=/home/container/config/prometheus,target=/etc/prometheus,readonly"
  ]
}
