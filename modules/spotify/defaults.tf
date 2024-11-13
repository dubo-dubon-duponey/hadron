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
    // xxx failed with dacodac digi+
    */
    // Will default to soft mixer - which is a problem - but alsa will fail for fixed gear like digi+ & qutest
    // "--mixer", "alsa",
    // "--initial-volume", "75",
    // "--enable-volume-normalisation",
  ]

  env = [
  ]

  volume        = [
    "cache-spotify:/magnetar/cache"
  ]

  cap_add     = []
}
