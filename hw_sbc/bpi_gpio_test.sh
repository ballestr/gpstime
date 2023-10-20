#!/bin/bash -x
## Armbian Buster on BananaPI Pro

##
declare -A gpio_map=(
#  ['GPIO18']=259 # physical pin 12
  ['GPIO24']=245 # physical pin 18, TESTED

#  ['GPIO17']=275 # physical pin 11
#  ['GPIO18']=226 # physical pin 12
)

cat /sys/kernel/debug/gpio

id=${gpio_map['GPIO24']}
echo $id
echo $id > /sys/class/gpio/export
ls -la /sys/class/gpio

dir=/sys/class/gpio/gpio$id
echo "out" > $dir/direction
echo 0 > $dir/value
cat $dir/value
