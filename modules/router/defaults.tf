defaults = {
  name       = "router"
  image      = "dubodubonduponey/router:bookworm-2024-02-20"
  privileged = false
  read_only  = true
  restart    = "always"
  devices    = []
  group_add  = []
  command    = []
  cap_add    = ["NET_BIND_SERVICE"]
  port       = [80, 443]


  env = [
    "MOD_BASICAUTH_ENABLED=true",
    "MOD_BASICAUTH_REALM=Is it a boy? Is it a girl? It's a poney!",
    "MOD_BASICAUTH_USERNAME=dubodubonduponey",
    "MOD_BASICAUTH_PASSWORD=JDJhJDE0JFpWS2pWaENtVUVJeU9hRHZDVFUxeE9Cd3RjQjU5Y2RQaHZQZGp4Z3hJZURIYWZ1VWNZa3Bp",

    "MOD_MDNS_ENABLED=true",
    "MOD_MDNS_HOST=highwayone",
    "MOD_MDNS_NAME=Highway 1",

    "ADVANCED_MOD_MDNS_TYPE=_http._tcp",
    "ADVANCED_MOD_MDNS_STATION=true",

    "MOD_HTTP_ENABLED=true",
    "MOD_HTTP_TLS_MODE=o@jsboot.net",
    "ADVANCED_MOD_HTTP_ADDITIONAL_DOMAINS=",
    "ADVANCED_MOD_HTTP_TLS_MIN=1.2",
    // At least macos webdav client is not happy with 1.3 - public properties still need 1.2 for now
    "ADVANCED_MOD_HTTP_TLS_AUTO=ignore_loaded_certs",

    "MOD_MTLS_ENABLED=true",
    "MOD_MTLS_MODE=verify_if_given",

    "DOMAIN=duncan.st",
  ]

  volume = [
  ]

  tmpfs = [
    "/tmp:rw,noexec,nosuid,size=1000000000"
  ]

  mount = [
    # rw
    "type=bind,source=/home/container/data/router,target=/data",
    "type=bind,source=/home/container/certs/dubo,target=/certs",

    "type=bind,source=/home/container/certs/dubo/pki/authorities/local/root.crt,target=/certs/mtls_ca.crt,readonly",
    "type=bind,source=/home/container/config/router/goello,target=/config/goello,readonly",
    "type=bind,source=/home/container/config/router/main.conf,target=/config/caddy/main.conf,readonly",
    "type=bind,source=/home/container/config/router/sites.d,target=/config/caddy/sites.d,readonly",
    "type=bind,source=/home/container/config/router/static,target=/config/caddy/static,readonly",
  ]

}
