#!/bin/bash

if ! [[ -c /dev/rtc1 ]]; then
  echo "## setup RTC ds3231"
  echo "ds3231" 0x68 > /sys/class/i2c-adapter/i2c-2/new_device
  sleep 1
fi

if ! [[ -c /dev/rtc1 ]]; then
  echo "## /dev/rtc1 not found, give up"
  exit 1
fi

echo "## RTC available:"
grep . /sys/class/rtc/rtc*/name
#cd /sys/class/rtc/
#grep . rtc*/time

echo -n "rtc0: "; hwclock -r -f /dev/rtc0
echo -n "rtc1: "; hwclock -r -f /dev/rtc1 --adjfile=/etc/adjtime.rtc1
echo -n "sys:  "; date "+%Y-%m-%d %H:%M:%S.%N"

function get_epochs {
rtc0_datetime="$(</sys/class/rtc/rtc0/date) $(</sys/class/rtc/rtc0/time)"
rtc1_datetime="$(</sys/class/rtc/rtc1/date) $(</sys/class/rtc/rtc1/time)"
sys_datetime="$(date '+%Y-%m-%d %H:%M:%S')"
rtc0_epoch=$(date --date "${rtc0_datetime}" +%s)
rtc1_epoch=$(date --date "${rtc1_datetime}" +%s)
sys_epoch=$(date --date "${sys_datetime}" +%s)
fake_epoch=$(date -f /etc/fake-hwclock.data +%s)
echo "rtc0: $rtc0_epoch"
echo "rtc1: $rtc1_epoch"
echo "sys:  $sys_epoch"
echo "fake: $fake_epoch"
}

function rtc1 {
  local action=$1
  local res=1
  while [[ $res -ne 0 ]]; do
    hwclock --$action -v -f /dev/rtc1 --adjfile=/etc/adjtime.rtc1
    res=$?
    echo "## - hwclock rtc1 $action res=$res"
    [[ $res -ne 0 ]] && sleep .1
  done
}

function update_from_rtc1() {
  local res=1
  if ! systemctl is-active -q chrony ; then
    echo "## updating sys from rtc1"
    rtc1 hctosys
  else
    echo "## chrony is running, do not update sys clock"
  fi
  echo "## updating rtc0 from sys"
  hwclock --systohc -v -f /dev/rtc0
  res=$?
  echo "## - hwclock rtc0 systohc res=$res"
}

get_epochs

if [[ $fake_epoch -gt $rtc1_epoch ]]; then
  echo "## rtc1 date is behind fake_hwclock"
  if [[ $sys_epoch -gt $fake_epoch ]]; then
    echo "## updating rtc1 from sys, better than nothing..."
    rtc1 systohc
  fi
fi

rtc0_date=$(</sys/class/rtc/rtc0/date) 
if [[ $rtc0_date == "1970-01-01" ]]; then
  echo "## rtc0 is in the far past, update from rtc1"
  update_from_rtc1
  get_epochs
  exit
fi
dt=$[sys_epoch-rtc1_epoch]
if [[ $dt -ne 0  ]]; then
  echo "## sys and rtc1 are not in sync, update from rtc1"
  update_from_rtc1
  get_epochs
fi
