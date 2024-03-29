defaults = {
  name          = "spotify"
  image         = "dubodubonduponey/spotify:bookworm-2024-03-01"
  privileged    = false
  read_only     = true
  restart       = "always"
  devices       = [
    "/dev/snd"
  ]
  group_add       = [
    "audio"
  ]
  command       = [
    // "--device", "default", # as seen from: `librespot --name foo --device ?`
    /*
    "--alsa-mixer-control", "PCM", # defaults to PCM
    "--alsa-mixer-device", "hw:0", # (from: aplay -l - defaults to default)
    */
    "--mixer", "alsa",
    "--initial-volume", "75",
    "--enable-volume-normalisation",
  ]

  env = [
    "PORT=10042",
    "OUTPUT=alsa",
  ]

  volume        = [
    "cache-spotify:/magnetar/cache"
  ]

  cap_add     = []
}
