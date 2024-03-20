defaults = {
  name        = "hadron-mac"
  driver      = "macvlan"
  attachable  = false
  internal    = false
  ipv6        = false
  parent      = "eth0"
  ipvlan_mode = "l2"
  subnet      = []
  gateway     = []
  aux_address = []
  ip_range    = []
}
