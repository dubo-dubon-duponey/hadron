defaults = {
  name          = "raat"
  image         = "dubodubonduponey/roon:bridge-bookworm-2023-09-05"
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
    "/tmp:rw,noexec,nosuid,size=1000000000"
  ]
  volume        = [
    "/data"
  ]
}
