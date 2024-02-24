defaults = {
  name          = "airplay"
  image         = "dubodubonduponey/airplay:bookworm-2023-09-05"
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
    // Required because of airplay protocol using a privileged port
    "NET_BIND_SERVICE",
  ]

  env           = [
    "PORT=7000",

    "OUTPUT=alsa",
  ]

  tmpfs         = [
    "/tmp:rw,noexec,nosuid,size=1000000000"
  ]

  volume        = [
    "run-airplay:/run/avahi-daemon"
  ]
}
