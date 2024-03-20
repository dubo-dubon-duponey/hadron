defaults = {
  name        = "hadron-ip"
  driver      = "ipvlan"
  attachable  = false
  internal    = false
  ipv6        = false
  parent      = "wlan0"
  ipvlan_mode = ""
  subnet      = []
  gateway     = []
  aux_address = []
  ip_range    = []
}
