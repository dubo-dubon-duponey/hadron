defaults = {
  name        = "hadron-bridge"
  driver      = "macvlan"
  parent      = "eth0"
  attachable  = false
  internal    = false
  ipv6        = false
  ipvlan_mode = "l2"
  subnet      = []
  gateway     = []
  aux_address = []
  ip_range    = []
}
