io_mode = "async"

node "dacodac" {

}

volumes_root = "foo"

# Generic configuration
variable "volumes_root" {
  description = "Root folder for all volume mounts (except media files)"
  default     = "/home/container"
}

service "http" "web_proxy" {
  listen_addr = var.volumes_root

  process "main" {
    command = ["/usr/local/bin/awesome-app", "server"]
  }

  process "mgmt" {
    command = ["/usr/local/bin/awesome-app", "mgmt"]
  }
}
