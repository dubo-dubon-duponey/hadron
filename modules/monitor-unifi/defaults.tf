defaults = {
  name          = "monitor-unifi"
  image         = "ghcr.io/unpoller/unpoller:v2"
  privileged    = false
  read_only     = true
  restart       = "always"
  devices       = []
  group_add     = []
  cap_add       = []

  env           = [
    "XDG_DATA_HOME=/data",
    "XDG_DATA_DIRS=/data",
    "XDG_CONFIG_HOME=/tmp/config",
    "XDG_CONFIG_DIRS=/config",
    "XDG_RUNTIME_DIR=/tmp/runtime",
    "XDG_STATE_HOME=/tmp/state",
    "XDG_CACHE_HOME=/tmp/cache",
  ]

  port          = 9130

  // pid           = "host"
  // network       = ["host"]

  command       = [
  ]

  mount        = [
    # ,rslave
    # "type=bind,source=/,target=/host,bind-propagation=rslave,readonly"
  ]

}
