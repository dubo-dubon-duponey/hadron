####################################################################
# Default values for this container
# Some values can be overridden with variables (image name, nickname, port)
####################################################################

  defaults = {
    name      = "share"
    image         = "dubodubonduponey/samba:bookworm-2023-09-05"
    privileged    = false
    // XXX need to test config
    read_only     = false // true
    restart       = "always"
    devices       = []
    group_add     = []
    command       = []
    cap_add  = [
      # Required to bind
      "NET_BIND_SERVICE",
      # These caps are only required for user account management
      # Ideally, that should be not granted to runtime image then
      # But instead a separate instance should operate "one-time" on the same volumes
      "CHOWN",
      "FOWNER",
      "SETUID", "SETGID",
      "DAC_OVERRIDE",
      // "LINUX_IMMUTABLE",
    ]
    user = "root"

    env           = [
    ]

    volume       = [
      "data-samba:/data:rw",
      "etc-samba:/etc:rw"
    ]

    tmpfs         = [
      "/tmp:rw,noexec,nosuid,size=1000000000"
    ]

    mount        = [
      # rw
      "type=bind,source=/home/wimp/TimeMachine,target=/media/timemachine",
      "type=bind,source=/home/data/share,target=/media/share",
      "type=bind,source=/home/data/home,target=/media/home",
    ]

  }
