#!/bin/bash
## setup CPU power management on the Banana PI M1+
## fix the clock to a relatively low value
## keeps the heat low, which is good for the stability of the RTC oscillators etc

## LED
echo "cpu" > /sys/class/leds/bananapro\:green\:usr/trigger

## CPU Frequency control
## https://wiki.debian.org/CpuFrequencyScaling#Configuration
## cpufreq-info
## https://www.kernel.org/doc/Documentation/cpu-freq/governors.txt
echo conservative > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo       800000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo       900000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo 25 > /sys/devices/system/cpu/cpufreq/conservative/freq_step
echo 90 > /sys/devices/system/cpu/cpufreq/conservative/up_threshold
echo 80 > /sys/devices/system/cpu/cpufreq/conservative/down_threshold
echo 10 > /sys/devices/system/cpu/cpufreq/conservative/sampling_down_factor
#echo 1 > /sys/devices/system/cpu/cpufreq/conservative/io_is_busy


#awk '{printf ("Power: %0.2fA\n",$1/1000000); }' < /sys/devices/platform/sunxi-i2c.0/i2c-0/0-0034/axp20-supplyer.28/power_supply/ac/c
#awk '{printf ("Temp : %0.2fC\n",$1/1000); }'    < /sys/devices/platform/sunxi-i2c.0/i2c-0/0-0034/temp1_input
awk '{printf ("Power: %0.2fA\n",$1/1000000); }'  < /sys/devices/platform/soc/1c2ac00.i2c/i2c-1/1-0034/ac/amperage
awk '{printf ("Power: %0.2fV\n",$1/1000000); }'  < /sys/devices/platform/soc/1c2ac00.i2c/i2c-1/1-0034/ac/voltage
awk '{printf ("Temp : %0.2fC\n",$1/1000); }'     < /sys/devices/platform/soc/1c2b400.i2c/i2c-2/2-0068/hwmon/hwmon0/temp1_input
awk '{printf ("Freq : %0.0fMHz\n",$1/1000); }'   < /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq
