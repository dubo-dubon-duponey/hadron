defaults = {
  name          = "roon-endpoint"
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
    // Roon lock file goes there
    "/magnetar/runtime:rw,uid=2000,gid=65534,noexec,nosuid,size=1000000",
  ]
  volume        = [
    // ID needs to be persisted so that restarts of the container does not fuck-up Roon config
    "data-roon-endpoint:/magnetar/user/data"
  ]
}
