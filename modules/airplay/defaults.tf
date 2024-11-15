defaults = {
  name          = "airplay"
  image         = "dubodubonduponey/airplay:bookworm-2024-09-01"
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
  cap_add       = [
    // Required because of time protocol using a privileged port
    "NET_BIND_SERVICE",
  ]

  tmpfs         = [
    "/magnetar/cache:rw,uid=2000,gid=65534,noexec,nosuid,size=1000000000",
    "/magnetar/runtime:rw,uid=2000,gid=65534,noexec,nosuid,size=1000000",
    "/magnetar/state:rw,uid=2000,gid=65534,noexec,nosuid,size=1000000",
    "/magnetar/state/avahi-daemon:rw,uid=101,gid=102,noexec,nosuid,size=1000000",
  ]
}
