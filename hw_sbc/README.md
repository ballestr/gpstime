# SBC Hardware

Parts related to the hardware of SBCs that I'm using to experiment with GPS+NTP.

* Banana PI M1+ with 
  * onboard RT, 
  * DS3231 GPIO RT clock 
  * USB GPS, 
  * hacked for adding PPS pulse to GPIO pin, 
  * external GPS antenna

* Plain RasPI 3 or 4 with 
  * USB GPS

## hw information
```
apt install lshw hwinfo
```

```
root@bananapi:~/config# cat /proc/device-tree/model ; echo
LeMaker Banana Pro
root@bananapi:~# cat /proc/device-tree/compatible ; echo
lemaker,bananaproallwinner,sun7i-a20
```

```
sash@rpi3:~ $ cat /proc/device-tree/model ; echo
Raspberry Pi 3 Model B Rev 1.2
sash@rpi3:~ $ cat /proc/device-tree/compatible ; echo
raspberrypi,3-model-bbrcm,bcm2837
```

## hwsetup_boot service

