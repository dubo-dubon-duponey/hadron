# Printing

Is a total shitshow.

In 2024, you basically need CUPS.
Samba is not required per-se (at least for macOS clients).

You need to mount both /dev/usb and /dev/bus.

CUPS requires Avahi for announces.
Unclear if (or not) it does require dbus as well.

Then you can:
- check that cups sees the printer: `/usr/lib/cups/backend/usb`
- check that cups exposes it: `lpinfo -lv`
- allow cups: `cupsctl --share-printers --remote-any --remote-admin`
- explicitely add the printer:
```bash
  lpadmin -p "Magnetosphere" -D "Magnetosphere" \
    -v "usb://Brother/HL-L2340D%20series" \
    -m drv:///brlaser.drv/brl2340d.ppd \
    -u allow:all \
    -o cupsIPPSupplies=true \
    -o cupsSNMPSupplies=true \
    -o PageSize=Legal \
    -E
```

Printer should be:
`direct usb://Brother/HL-L2340D%20series`

- get printer info:
`ipptool -tv ipp://localhost:631/printers/Magnetosphere /usr/share/cups/ipptool/get-printer-attributes.test`

Permission model is a train-wreck and mixes together frontend and API.

If you still want samba:

- check that samba has cups support: `smbd -b | grep "HAVE_CUPS"`
- reload samba: `smbcontrol all reload-config`

Note: did not make Samba work and stuck with CUPS ultimately.
Separating concerns.
