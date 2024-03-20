defaults = {
  name          = "raat"
  image         = "dubodubonduponey/roon:bridge-bookworm-2024-03-01"
  privileged    = false
  read_only     = true
  restart       = "always"
  devices       = [
    "/dev/snd",
  ]
  group_add     = [
    "audio",
  ]
  command       = [
  ]
  cap_add     = [
  ]

  tmpfs         = [
    // "/tmp:rw,uid=2000,gid=65534,noexec,nosuid,size=1000000000"
  ]
  volume        = [
  // ID needs to persist so that restarts of the container does not fuck-up Roon config
    "data-raat:/magnetar/user/data"
  ]
}
