defaults = {
  name      = "print"
  image         = "dubodubonduponey/cups:bookworm-2024-09-01"
  privileged    = false
  // XXX breaks cupctl - too lazy to figure out why - so, read write it is for now
  read_only     = false
  restart       = "always"
  user          = "root"

  devices       = [
    "/dev/usb",
    "/dev/bus",
  ]
  group_add     = [
    "lp"
  ]
  command       = []
  cap_add  = []

  env           = []

  volume       = [
    "etc-cups:/etc/cups:rw",
    "run-cups:/run/avahi-daemon",
  ]

  tmpfs         = [
    "/tmp:rw,noexec,nosuid,size=1000000000"
  ]

  mount        = []
}


/*
# Printer configuration file for CUPS v2.4.2
# Written by cupsd
# DO NOT EDIT THIS FILE WHEN CUPSD IS RUNNING
NextPrinterId 4
<Printer Brother_HL-L2340D_series>
PrinterId 3
UUID urn:uuid:7ea81125-213b-3171-761f-91b19e264cda
Info Brother HL-L2340D series
Location
MakeModel Brother HL-L2340D series, using brlaser v6
DeviceURI usb://Brother/HL-L2340D%20series
State Idle
StateTime 1709773892
ConfigTime 1709773892
Type 4180
Accepting Yes
Shared Yes
JobSheets none none
QuotaPeriod 0
PageLimit 0
KLimit 0
OpPolicy default
ErrorPolicy retry-job
</Printer>
<Printer Magnetosphere>
PrinterId 2
UUID urn:uuid:53f43b9b-1d97-3f77-4fee-88285b8cde93
Info Magnetosphere
DeviceURI usb://Brother/HL-L2340D%20series
State Idle
StateTime 1709773868
ConfigTime 1709773868
Type 4
Accepting Yes
Shared Yes
JobSheets none none
QuotaPeriod 0
PageLimit 0
KLimit 0
OpPolicy default
ErrorPolicy retry-job
</Printer>
*/
