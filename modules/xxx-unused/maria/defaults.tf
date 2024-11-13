defaults {
  name          = "maria"
  image         = "library/mariadb:11-jammy"
  privileged    = false
  read_only     = true
  devices       = []
  group_add     = []
  command       = [
    "mysqld",
    "--datadir=/data",
    "--port=3306",
    "--transaction-isolation=READ-COMMITTED",
    "--character-set-server=utf8mb4",
    "--collation-server=utf8mb4_unicode_ci",
    "--max-connections=512",
    "--innodb-rollback-on-timeout=OFF",
    "--innodb-lock-wait-timeout=120"
  ]
  cap_add  = [
    "CAP_CHOWN",
    "CAP_DAC_OVERRIDE",
    "SETUID",
    "SETGID",
  ]
  port          = 3306
}
