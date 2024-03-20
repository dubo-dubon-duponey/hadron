defaults = {
  name          = "monitor-ui"
  image         = "grafana/grafana:10.2.4-ubuntu"
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

    "GF_SERVER_HTTP_PORT=4242",
    "GF_ANALYTICS_REPORTING_ENABLED=false",
    "GF_ANALYTICS_CHECK_FOR_UPDATES=false",
    "GF_ANALYTICS_CHECK_FOR_PLUGIN_UPDATES=false",
    "GF_LOG_LEVEL=warn"
  ]
  command       = []

  mount        = [
    # rw
    "type=bind,source=/home/container/data/grafana,target=/var/lib/grafana",
    # read-only
    "type=bind,source=/home/container/config/grafana/etc,target=/etc/grafana,readonly",
    "type=bind,source=/home/container/config/grafana/plugins,target=/usr/share/grafana/plugins-bundled,readonly"

  ]
}
