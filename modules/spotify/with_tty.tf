defaults = {
  devices         = [
    "/dev/snd",
    "/dev/tty2",
    "/dev/fb0",
  ]
  group_add       = [
    "audio",
    "tty",
    "video",
  ]

  cap_add     = [
    "CAP_SYS_TTY_CONFIG"
  ]
}
