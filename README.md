# gpstime
Tools and explorations on GPS and NTP.

Goal: build an NTP source that has a precision better than 1ms, all the time. 

* 1ms is not a particularly difficult goal in itself
* but doing it reliably, in presence of network or GPS signal loss requires some careful thinking and testing
* and this needs to be demonstrable, requiring proper monitoring, metrics, alerts
* and finally, what are actually the benchmark references that are reliably precise to better than 1ms, from a random internet endpoint?

See also https://github.com/ballestr/chronyd_exporter

## Important stuff

* Have good GPS antenna reception
* Use Pulse Per Second
* Use dedicated hardware

## Install
```
# git clone https://github.com/ballestr/gpstime.git /opt/gpstime
# /opt/gpstime/hw_sbc/install.hwsbc.sh
```

## basics

* https://en.wikipedia.org/wiki/Network_Time_Protocol
* https://opensource.com/article/18/12/manage-ntp-chrony
* https://www.ntppool.org/join/configuration.html Configuration recommendations for servers joining the pool
* NTP Pools
  * https://www.ntppool.org/zone/europe
  * https://services.renater.fr/ntp/serveurs_francais
* https://questions.ntp.narkive.com/bKcPTXXY/ntp-how-to-measure-the-quality-of-ntp-server

### Metrics

* https://www.chrony.eu/status/1-pool

## Reference time servers
* CH: https://www.metas.ch/metas/en/home/fabe/zeit-und-frequenz/time-dissemination.html
