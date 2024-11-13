# HifiBerry Digi Pro

## Modules for hifiberry

* digi+:
  * dtoverlay=hifiberry-digi
* amp2:
 * Kernel < 6.1.77: dtoverlay=hifiberry-dacplus
 * Kernel >=  6.1.77: dtoverlay=hifiberry-dacplus-std
* dac+ pro:
 * Kernel < 6.1.77: dtoverlay=hifiberry-dacplus
 * Kernel >=  6.1.77: dtoverlay=hifiberry-dacplus-pro

## General config

https://www.hifiberry.com/docs/software/configuring-linux-3-18-x/

/boot/config.txt

```
# In some cases (dac+ pro and somewhat confirmed with digi+), module might not load
force_eeprom_read=0

# To debug in dmesg
# dtdebug=1

# digi+
#dtoverlay=hifiberry-digi
# OR
# amp2, dac+ pro
#dtoverlay=hifiberry-dacplus

# Disable wifi
dtoverlay=disable-wifi
# Disable bluetooth
dtoverlay=bt=off
# Disable  hdmi audio
dtoverlay=vc4-kms-v3d,noaudio
# Disable  onboard audio
dtparam=audio=off

```

## Notes

Dacodac:
- usable card for digi+ is `hw:CARD=sndrpihifiberry,DEV=0`
- over USB would have been: `default:CARD=Qutest`
- USB sound quality is not good (click, drops) - still undiagnosed why and just moving to S/PDIF
- no apparent limitation so far with S/PDIF, but need to try with high-quality and mono samples
- no alsa mixing available, so, airplay has sound disabled, and spotify is softvol only

## Debugging

```bash
aplay -l

aplay -L

for i in /proc/asound/card?/pcm*/sub?/hw_params;  do echo $i; cat $i; done
```

```bash
# Uncomment some or all of these to enable the optional hardware interfaces
#dtparam=i2c_arm=on
#dtparam=i2s=on
#dtparam=spi=on
```

