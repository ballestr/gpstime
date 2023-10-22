#!/bin/bash
install -m 644 10_noise.conf  70_local_split_gpsd.conf  70_local_split_prom.conf /etc/rsyslog.d
systemctl restart rsyslog
