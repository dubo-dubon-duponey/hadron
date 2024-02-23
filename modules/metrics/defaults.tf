defaults = {
  name          = "metrics"
  image         = "bitnami/prometheus:2-debian-12" // dubodubonduponey/postgres:bullseye-2021-11-01
  privileged    = false
  read_only     = true
  restart       = "always"
  devices       = []
  group_add     = []
  command       = [
    "--config.file=/opt/bitnami/prometheus/conf/prometheus.yml",
    "--storage.tsdb.path=/opt/bitnami/prometheus/data",
    "--web.console.libraries=/opt/bitnami/prometheus/conf/console_libraries",
    "--web.console.templates=/opt/bitnami/prometheus/conf/consoles",
  ]
  cap_add  = [
  ]
  port          = 9090

  env           = [
    "XDG_DATA_HOME=/data",
    "XDG_DATA_DIRS=/data",
    "XDG_CONFIG_HOME=/tmp/config",
    "XDG_CONFIG_DIRS=/config",
    "XDG_RUNTIME_DIR=/tmp/runtime",
    "XDG_STATE_HOME=/tmp/state",
    "XDG_CACHE_HOME=/tmp/cache",
  ]

  mount        = [
    # rw
    "type=bind,source=/home/container/data/prometheus,target=/opt/bitnami/prometheus/data",
    "type=bind,source=/home/container/config/prometheus,target=/opt/bitnami/prometheus/conf",
    # ro
    "type=bind,source=/home/container/certs/ca.crt,target=/certs/ca.pem"
  ]
}
