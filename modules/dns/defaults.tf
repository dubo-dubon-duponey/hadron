defaults = {
  name          = "dns"
  image         = "dubodubonduponey/dns:bookworm-2024-03-01"
  privileged    = false
  read_only     = true
  restart       = "always"
  port          = [53]
  devices       = []
  group_add     = []
  command       = []
  cap_add       = ["NET_BIND_SERVICE"]
  env           = [
    "HEALTHCHECK_URL=127.0.0.1:53",
    "HEALTHCHECK_QUESTION=dns.autonomous.healthcheck.duncan.st",
    "HEALTHCHECK_TYPE=udp",
    # XXX should only be exposed on internal network... Not clear how to do that currently...
    # At least do not expose over ipv6
    # Furthermore, internal com does not solve the problem of remote hosts.
    # discovery is mandatory here, but same, not sure how to do it
    "METRICS_LISTEN=0.0.0.0:4242",

    "DNS_PORT=53",
    # "DNS_OVER_GRPC_PORT=5553",
    "DNS_STUFF_MDNS=false",

    "DNS_FORWARD_ENABLED=true",
    "DNS_FORWARD_UPSTREAM_NAME=cloudflare-dns.com",
    "DNS_FORWARD_UPSTREAM_IP_1=tls://1.1.1.1",
    "DNS_FORWARD_UPSTREAM_IP_2=tls://1.0.0.1",

    "DNS_OVER_TLS_ENABLED=false",
    "DNS_OVER_TLS_DOMAIN=",
    "DNS_OVER_TLS_PORT=",
    "DNS_OVER_TLS_LEGO_PORT=",
    "DNS_OVER_TLS_LEGO_EMAIL=",
    "DNS_OVER_TLS_LE_USE_STAGING=false",
  ]

  # XXX this is ill fated - see above and the issues document
  publish = ["4242:4242/tcp"]

  volume      = [
  // Used solely when lego / certificates are in play
    "data-dns:/magnetar/user/data"
  ]
}
