defaults = {
  name          = "roon"
  image         = "dubodubonduponey/roon:server-bookworm-2024-03-01"
  privileged    = false
  read_only     = true
  restart       = "always"
  devices       = []
  group_add     = []
  command       = []
  cap_add       = ["NET_BIND_SERVICE"]
  port          = 443

  tmpfs         = [
  ]

  mount        = [
    # rw
    "type=bind,source=/home/container/data/roon,target=/data",
    # ro
    "type=bind,source=/home/data/audio,target=/music,readonly",
  ]
}
