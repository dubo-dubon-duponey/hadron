defaults = {
  name          = "monitor-container"
  image         = "gcr.io/cadvisor/cadvisor:v0.47.2"
  privileged    = true
  read_only     = true
  restart       = "always"
  devices       = [
    "/dev/kmsg"
  ]
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

  port          = 4242

  command       = [
    "--docker_only=true",
    "--port=4242",
    "--raw_cgroup_prefix_whitelist=/docker/"
  ]
  security_opt = [
    // "seccomp=default.json"
  ]

  mount        = [
    "type=bind,source=/var/run,target=/var/run",
    "type=bind,source=/,target=/rootfs,bind-propagation=rslave,readonly",
    "type=bind,source=/sys,target=/sys,readonly",
    "type=bind,source=/var/lib/docker,target=/var/lib/docker,readonly",
//    "type=bind,source=/dev/disk,target=/dev/disk,readonly",
  ]
}
