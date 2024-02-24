defaults = {
  name          = "monitor-host"
  image         = "prom/node-exporter:v1.7.0"
  // XXX not clear why we would need it privileged
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

    "--path.rootfs=/host",
  ]

  pid           = "host"

  mount        = [
    # ,rslave
    "type=bind,source=/,target=/host,bind-propagation=rslave,readonly"
  ]

}
