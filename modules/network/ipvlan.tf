defaults = {
  name        = "hadron-bridge"
  driver      = "ipvlan"
  parent      = "wlan0"
  attachable  = false
  internal    = false
  ipv6        = false
  ipvlan_mode = ""
  subnet      = []
  gateway     = []
  aux_address = []
  ip_range    = []
}
