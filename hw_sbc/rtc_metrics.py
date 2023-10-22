#!/bin/python3
## RTC metrics exporter

import os
import sys
import time
#import datetime
from datetime import datetime
if sys.version_info < (3, 0):
    from cStringIO import StringIO
else:
    from io import StringIO

## avoid time zone mess, always use UTC here
os.environ['TZ'] = 'Etc/UTC'
time.tzset()

# Number of seconds between updates
update_interval = 15

# metrics file to write
#workfile="/var/lib/prometheus/node-exporter/rtc.prom"
workfile="/dev/stdout"

def rtc_diff(rtc,rtcname,offset,output):
  t1=time.time()
  wait=1.-(t1%1)+offset
  time_sysr=t1+wait
  time.sleep( wait )
  time_sys0=time.time()
  tstr_rtc=os.popen("hwclock -r --rtc /dev/%s --adjfile=/etc/adjtime.%s"%(rtc,rtc)).read().rstrip()
  time_rtc=datetime.strptime(tstr_rtc, '%Y-%m-%d %H:%M:%S.%f+00:00')
  time_sys1=time.time()
  ## dtr jumps even more than dt0, not helpful
  print("#%s %s"%(rtc,rtcname) ,file=output)
  labels='rtc="%s",name="%s"'%(rtc,rtcname)
  #print ("#%s %.6f %s %.6f"%(rtc,time_sysr,"dtr:",(time_rtc.timestamp()-time_sysr)) ,file=output)
  print ("#%s %.6f %s %.6f"%(rtc,time_sys0,"dt0:",(time_rtc.timestamp()-time_sys0)) ,file=output)
  print ("#%s %.6f %s %s"%(rtc,time_rtc.timestamp(),tstr_rtc,time_rtc) ,file=output)
  print ("#%s %.6f %s %.6f"%(rtc,time_sys1,"dt1:",(time_sys1-time_rtc.timestamp())) ,file=output)
  print ('rtc_rtc_epoch{%s} %.6f'%(labels,time_rtc.timestamp()),file=output)
  #print ('rtc_sys_dtr_seconds{%s} %.6f'%(labels,(time_sysr-time_rtc.timestamp())),file=output)
  print ('rtc_sys_dt0_seconds{%s} %.6f'%(labels,(time_sys0-time_rtc.timestamp())),file=output)
  print ('rtc_sys_dt1_seconds{%s} %.6f'%(labels,(time_sys1-time_rtc.timestamp())),file=output)
  print ('rtc_measure_seconds{%s} %.6f'%(labels,(time_sys1-time_sys0)),file=output)

with open("/sys/class/rtc/rtc0/name") as file :
  rtc0name=file.read().rstrip()
with open("/sys/class/rtc/rtc1/name") as file :
  rtc1name=file.read().rstrip()

init=1
while True:
  output = StringIO()
  t0=time.time()
  rtc_diff("rtc1",rtc1name,0.900,output)
  rtc_diff("rtc0",rtc0name,0.500,output)

  print (output.getvalue())
  if init!=1 :
    with open(workfile,"w") as f:
      print (output.getvalue(),file=f)
  output.close()
  init=0

  ## wait for next step, compensating for the time taken
  ## otherwise we end up with sample aliasing
  t1=time.time()
  time.sleep(update_interval-(t1-t0))


#echo -n "rtc0: "; hwclock -r -f /dev/rtc0 --adjfile=/etc/adjtime.rtc0
#echo -n "sys:  "; date "+%Y-%m-%d %H:%M:%S.%N"
#echo -n "rtc1: "; hwclock -r -f /dev/rtc1 --adjfile=/etc/adjtime.rtc1
#echo -n "sys:  "; date "+%Y-%m-%d %H:%M:%S.%N"
