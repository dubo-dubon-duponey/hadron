defaults = {
  name        = "hadron-mac"
  driver      = "macvlan"
  attachable  = false
  internal    = false
  ipv6        = false
  parent      = "eth0"
  # Docker only
  # ipvlan_mode = "l2"
  # Containerd / CNI does not support the option
  subnet      = []
  gateway     = []
  aux_address = []
  ip_range    = []
}
