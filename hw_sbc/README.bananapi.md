# SinoVoip/BPI Banana PI BPI-M1+

A clone of the LeMaker BananaPro
* https://wiki.banana-pi.org/Banana_Pi_BPI-M1%2B
* https://linux-sunxi.org/LeMaker_Banana_Pro
* https://web.archive.org/web/20221203021624/http://forum.lemaker.org/article-43-1.html

Running Armbian 
- https://www.armbian.com/banana-pi-pro/ 
- https://www.armbian.com/banana-pi-plus/
```
# cat /etc/os-release 
PRETTY_NAME="Armbian 23.8.1 bullseye"
NAME="Debian GNU/Linux"
VERSION_ID="11"
VERSION="11 (bullseye)"
VERSION_CODENAME=bullseye
ID=debian
# cat /etc/debian_version
11.7
```
Seems to be better with `fdtfile=sun7i-a20-bananapro.dtb` than with `fdtfile=sun7i-a20-bananapi-m1-plus.dtb`, don't remember the details right now.

### scattered notes

* https://organicdesign.nz/Banana_Pi

```
cat /proc/device-tree/model
```

https://www.linuxbabe.com/ubuntu/connect-to-wi-fi-from-terminal-on-ubuntu-18-04-19-04-with-wpa-supplicant



# https://gpsd.gitlab.io/gpsd/index.html

systemctl restart gpsd does not work well, do a full stop and start
systemctl stop gpsd; systemctl start gpsd


# https://pypi.org/project/gpsd-prometheus-exporter/
# git clone https://github.com/markopolo123/gpsd_prometheus_exporter
# apt install python3-pip python3-setuptools python3-wheel python3-gps python3-prometheus-client python3-venv
# pip3 install gpsd-py3 build
# cd gpsd_prometheus_exporter
# python3 -m build
# pip3 install dist/gpsd_prometheus_exporter-0.3.1.tar.gz 
# python3 main.py

## monitoring ntp / chrony
https://github.com/prometheus/node_exporter/blob/master/docs/TIME.md
https://www.mail-archive.com/chrony-users@chrony.tuxfamily.org/msg02179.html

## see also https://pypi.org/project/pizero-gpslog/

https://gpsd.gitlab.io/gpsd/gpsd-time-service-howto.html#_enabling_pps
apt install pps-tools
# no luck



