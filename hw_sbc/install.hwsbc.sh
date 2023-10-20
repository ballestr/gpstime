#!/bin/bash
## install with just a script, so much faster than Ansible or Puppet on these SBCs ;-)

install hwsetup_boot.service              /etc/systemd/system/
install prometheus-hwsbc-exporter.service /etc/systemd/system/
install prometheus-rtc-exporter.service   /etc/systemd/system/
