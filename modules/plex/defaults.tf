defaults = {
  name          = "plex"
  image         = "dubodubonduponey/plex:bookworm-2024-02-20"
  privileged    = false
  read_only     = false
  restart       = "always"
  devices       = []
  group_add     = []
  command       = []
  cap_add       = ["NET_BIND_SERVICE"]
  port          = [80, 443, 32400]

  tmpfs         = [
    "/tmp:rw,noexec,nosuid,size=1000000"
  ]

  mount        = [
    # rw
    "type=bind,source=/home/container/data/plex,target=/data",
    # ro
    "type=bind,source=/home/wimp/Tachyon/,target=/media,readonly",
  ]

  env = [
    // Disable these two
    "MDNS_ENABLED=false",
    "PROXY_HTTPS_ENABLED=false",
    "HEALTHCHECK_URL=http://127.0.0.1:32400/?healthcheck=",
    "DOMAIN=",
    "ADDITIONAL_DOMAINS=",
    "TLS=",
    "TLS_AUTO=",
    "AUTH=",
    "MDNS_HOST=",
    "MTLS=",
  ]
}
