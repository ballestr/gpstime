#!/bin/python3

## CPU Frequency control
#echo conservative > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
#echo       800000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
#echo      1000000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
#echo 50 > /sys/devices/system/cpu/cpufreq/conservative/up_threshold
#echo 10 > /sys/devices/system/cpu/cpufreq/conservative/sampling_down_factor
#echo 1 > /sys/devices/system/cpu/cpufreq/conservative/io_is_busy

from time import *
import getopt
import os
import sys
import time
import glob

if sys.version_info < (3, 0):
    from cStringIO import StringIO
else:
    from io import StringIO

BASE="node_hwsbc"
global output ## string buffer

def readfile(path) :
  with open(path, 'r') as file:
    data = file.read().replace('\n', '')
  return data

def gauge(name, value):
  global output
  print("%s_%s %f"%(BASE,name,value),file=output)

## using Industrial IO device sys interface
## https://www.kernel.org/doc/html/v4.15/driver-api/iio/core.html
## https://www.kernel.org/doc/Documentation/ABI/testing/sysfs-bus-iio
## https://wiki.analog.com/resources/tools-software/linux-software/libiio_internals
def rawtemp(metric,dir):
  if not(os.path.isdir(dir)): return
  try:
    name=  readfile(dir+'name')
  except IOError:
    name=""
    pass

  try:
    raw=   float(readfile(dir+'in_temp_raw'))
    offset=float(readfile(dir+'in_temp_offset'))
    scale= float(readfile(dir+'in_temp_scale'))
  except IOError:
    ## sensors reading fails from time to time
    ## don't bother with retry here, skip metric and wait next loop
    pass
  else:
    temp=(raw+offset)*scale/1000
    #echo "## ${BASE}_${metric} $temp [raw $raw offset $offset scale $scale]"
    if raw and raw>0 :
      gauge (metric+'_celsius{name="%s",path="%s"}'%(name,dir),temp)

def metrics():
  global output
  print("## metrics %s"%time.time(),file=output)
  gauge("timestamp",time.time())

  ## CPU clock
  dir="/sys/devices/system/cpu"
  gauge ("cpu0_freq_hertz",int(readfile(dir+"/cpu0/cpufreq/cpuinfo_cur_freq"))*1000)

  ## thermal
  dir="/sys/devices/virtual/thermal"
  #print(glob.glob(dir+"/thermal_zone*"))
  for d in glob.glob(dir+"/thermal_zone*"):
    name=os.path.basename(d)
    type=readfile(d+"/type")
    temp0=float(readfile(d+"/temp"))/1000
    offset=float(readfile(d+"/offset"))/1000
    temp=(temp0+offset)
    gauge ('thermal_celsius{name="'+name+'",type="'+type+'"}',temp)

  ## BananaPI power sensors
  #awk '{printf ("Power: %0.2fA\n",$1/1000000); }' < /sys/devices/platform/sunxi-i2c.0/i2c-0/0-0034/axp20-supplyer.28/power_supply/ac/c
  #awk '{printf ("Temp : %0.2fC\n",$1/1000); }'    < /sys/devices/platform/sunxi-i2c.0/i2c-0/0-0034/temp1_input
  dir="/sys/devices/platform/soc/1c2ac00.i2c/i2c-1/1-0034/ac"
  if os.path.isdir(dir):
    try:
      a=float(readfile(dir+"/amperage"))/1000000 ## this fails reading from time to time
      v=float(readfile(dir+"/voltage"))/1000000
    except IOError:
      ## sensors reading fails from time to time
      ## don't bother with retry here, skip metric and wait next loop
      pass
    else:
      gauge ('power_ampere',a)
      gauge ('power_volt',v)
      gauge ('power_watt',(a*v))

  ## RTC Clock at I2C address 0x68
  #dir="/sys/devices/platform/soc/1c2b400.i2c/i2c-2/2-0068/hwmon/hwmon0"
  #if os.path.isdir(dir):
  #  gauge ("temp_rtc_celsius",float(readfile(dir+"/temp1_input"))/1000)
  dir="/sys/class/hwmon/hwmon1"
  if os.path.isdir(dir):
    name=readfile(dir+"/name")
    temp=float(readfile(dir+"/temp1_input"))/1000
    gauge ('temp_rtc_celsius{name="%s"}'%(name),temp)

  #rawtemp ('temp_gpadc','/sys/devices/platform/soc/1c25000.rtp/sun5i-a13-gpadc-iio.0/iio:device0/')
  #rawtemp ('temp_axp20','/sys/devices/platform/soc/1c2ac00.i2c/i2c-1/1-0034/axp20x-adc/iio:device1/')
  rawtemp ('temp_iio','/sys/bus/iio/devices/iio:device0/')
  rawtemp ('temp_iio','/sys/bus/iio/devices/iio:device1/')

def main():
  global output
  workfile='/var/lib/prometheus/node-exporter/%s.prom'%(BASE)
  print("hwsbc_metrics.py starting %s"%(workfile))
  while True :
    output = StringIO()
    metrics()
    #print (output.getvalue())
    with open(workfile,"w") as f:
      print (output.getvalue(),file=f)
    output.close()
    sleep(15)

if __name__ == '__main__':
  main()
