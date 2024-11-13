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
    "XDG_DATA_HOME=/magnetar/user/data",
    "XDG_DATA_DIRS=/magnetar/system/data",
    "XDG_CONFIG_HOME=/magnetar/user/config",
    "XDG_CONFIG_DIRS=/magnetar/system/config",
    "XDG_RUNTIME_DIR=/magnetar/runtime",
    "XDG_STATE_HOME=/magnetar/state",
    "XDG_CACHE_HOME=/magnetar/cache",
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
