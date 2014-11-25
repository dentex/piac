#!/bin/bash

# This script name
SC=`basename $0`

function check_network {
  ping -c 1 -w 3 google.it > /dev/null 2>&1
  if [ "$?" -ne 0 ]; then
    exit 1
  fi
}

function get_temp {
  CPU_TEMP=$(cat /sys/class/thermal/thermal_zone0/temp)
  CPU_TEMP_I=$(($CPU_TEMP/1000))
  CPU_TEMP_D=$(($CPU_TEMP/100))
  CPU_TEMP_M=$(($CPU_TEMP_D % $CPU_TEMP_I))

  echo $CPU_TEMP_I.$CPU_TEMP_M
}

function cats {
  cputemp=`get_temp`

  t8=`cat /home/pi/log/last_t8_status`
  co2=`cat /home/pi/log/last_co2_status`
  fan=`cat /home/pi/log/last_fan_step`
  leds=`cat /home/pi/log/last_night_leds_level`
}

function dweet {
  curl -d "cpu-temp=$cputemp" "http://dweet.io/dweet/for/piac" > /dev/null 2>&1
  curl -d "t8-status=$t8" "http://dweet.io/dweet/for/piac" > /dev/null 2>&1
  curl -d "co2-status=$co2" "http://dweet.io/dweet/for/piac" > /dev/null 2>&1
  curl -d "lid-fan-step=$fan" "http://dweet.io/dweet/for/piac" > /dev/null 2>&1
  curl -d "night-leds-level=$leds" "http://dweet.io/dweet/for/piac" > /dev/null 2>&1
}

check_network
cats
dweet
