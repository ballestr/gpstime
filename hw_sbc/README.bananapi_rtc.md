https://wiki.banana-pi.org/BPI_RTC_real_time_Module

```
root@bananapi:~/config# i2cdetect -y 2
     0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
00:          -- -- -- -- -- -- -- -- -- -- -- -- -- 
10: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
20: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
30: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
40: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
50: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
60: -- -- -- -- -- -- -- -- 68 -- -- -- -- -- -- -- 
70: -- -- -- -- -- -- -- --                         
```

Then appears as `rtc1`:
```
# grep . /sys/class/rtc/rtc*/name
/sys/class/rtc/rtc0/name:sunxi-rtc 1c20d00.rtc
/sys/class/rtc/rtc1/name:rtc-ds1307 2-0068
```

```
hwclock -w -f /dev/rtc1 ## ==> Write the system time to file in /dev/rtc1
hwclock -r -f /dev/rtc1 ## ==> Read the time in /dev/rtc1
hwclock -s -f /dev/rtc1 ## => Read the time in /dev/rtc1 and write the system time to file as well.
```


There is also a temp sensor:
```
root@bananapi:~/config# cat /sys/devices/platform/soc/1c2b400.i2c/i2c-2/2-0068/hwmon/hwmon0/temp1_input
32500
```

And node_exporter found it automatically :
```
root@bananapi:~/config# curl -s localhost:9100/metrics | grep hwmon
# HELP node_hwmon_chip_names Annotation metric for human-readable chip names
# TYPE node_hwmon_chip_names gauge
node_hwmon_chip_names{chip="i2c_2_2_0068",chip_name="ds3231"} 1
# HELP node_hwmon_temp_celsius Hardware monitor for temperature (input)
# TYPE node_hwmon_temp_celsius gauge
node_hwmon_temp_celsius{chip="i2c_2_2_0068",sensor="temp1"} 32.5
```
