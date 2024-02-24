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
    "XDG_DATA_HOME=/data",
    "XDG_DATA_DIRS=/data",
    "XDG_CONFIG_HOME=/tmp/config",
    "XDG_CONFIG_DIRS=/config",
    "XDG_RUNTIME_DIR=/tmp/runtime",
    "XDG_STATE_HOME=/tmp/state",
    "XDG_CACHE_HOME=/tmp/cache",
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
