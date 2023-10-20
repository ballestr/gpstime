
## CPU Frequency control
#echo conservative > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
#echo       800000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
#echo      1000000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
#echo 50 > /sys/devices/system/cpu/cpufreq/conservative/up_threshold
#echo 10 > /sys/devices/system/cpu/cpufreq/conservative/sampling_down_factor
#echo 1 > /sys/devices/system/cpu/cpufreq/conservative/io_is_busy

BASE="node_hwsbc"

function gauge {
  local name=$1
  local value=$2
  printf "%s %f\n" $name $value
}

## using Industrial IO device sys interface
## https://www.kernel.org/doc/html/v4.15/driver-api/iio/core.html
## https://www.kernel.org/doc/Documentation/ABI/testing/sysfs-bus-iio
## https://wiki.analog.com/resources/tools-software/linux-software/libiio_internals
function rawtemp {
  local metric=$1
  local dir=$2
  if [[ -d $dir ]] ; then
    raw=$(<$dir/in_temp_raw)
    offset=$(<$dir/in_temp_offset)
    scale=$(<$dir/in_temp_scale)
    temp=$(python -c "print( (1.*$raw+($offset))*($scale) /1000 )") #confusedmc"
    echo "## ${BASE}_${metric} $temp [raw $raw offset $offset scale $scale]"
    if [[ $raw && $raw -gt 0 ]]; then
      gauge ${BASE}_${metric}_celsius $temp
    fi
  fi
}

function metrics {
echo "## metrics $(date)"
gauge ${BASE}_timestamp $(date +%s)

dir=/sys/devices/system/cpu/
gauge ${BASE}_cpu0_freq_hertz  $(awk '{printf ("%0.0f",$1*1000); }' <$dir/cpu0/cpufreq/cpuinfo_cur_freq) #confusedmc'

dir=/sys/devices/virtual/thermal
for d in $dir/thermal_zone*; do
  name=$(basename $d)
  type=$(<$d/type)
  temp0=$(awk '{printf ("%0.2f",$1/1000); }' < $d/temp)  #confusedmc'
  offset=$(awk '{printf ("%0.2f",$1/1000); }' < $d/offset)  #confusedmc'
  temp=$(python -c "print($temp0+($offset))") #confusedmc"
  gauge "${BASE}_${name}_celsius{type=\"$type\"}" $temp
done

## BananaPI power sensors
#awk '{printf ("Power: %0.2fA\n",$1/1000000); }' < /sys/devices/platform/sunxi-i2c.0/i2c-0/0-0034/axp20-supplyer.28/power_supply/ac/c
#awk '{printf ("Temp : %0.2fC\n",$1/1000); }'    < /sys/devices/platform/sunxi-i2c.0/i2c-0/0-0034/temp1_input
dir=/sys/devices/platform/soc/1c2ac00.i2c/i2c-1/1-0034/ac/
if [[ -d $dir ]]; then
  a=$(awk '{printf ("%0.2f",$1/1000000); }' < $dir/amperage) #confusedmc'
  v=$(awk '{printf ("%0.2f",$1/1000000); }' < $dir/voltage)  #confusedmc'
  if [ $a ] ; then
    gauge ${BASE}_power_ampere $a
    gauge ${BASE}_power_volt   $v
    gauge ${BASE}_power_watt   $(python -c "print($a*$v)") #confusedmc"
  fi
fi

## RTC Clock at I2C address 0x68
dir=/sys/devices/platform/soc/1c2b400.i2c/i2c-2/2-0068/hwmon/hwmon0
if [[ -d $dir ]]; then
  gauge ${BASE}_temp_rtc_celsius $(awk '{printf ("%0.2f",$1/1000); }' < $dir/temp1_input) #confusedmc'
fi

rawtemp temp_gpadc /sys/devices/platform/soc/1c25000.rtp/sun5i-a13-gpadc-iio.0/iio:device0/
rawtemp temp_axp20 /sys/devices/platform/soc/1c2ac00.i2c/i2c-1/1-0034/axp20x-adc/iio:device1/
}

while true; do
  if [[ $1 = "--test" ]]; then
    metrics
  else
    metrics | sponge /var/lib/prometheus/node-exporter/${BASE}.prom
  fi
  sleep 15
done

