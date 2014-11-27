#!/bin/bash

# This script name
SC=`basename $0`

function check_network {
  ping -c 1 -w 3 google.it > /dev/null 2>&1
  if [ "$?" -ne 0 ]; then
    exit 1
  fi
}

function getCpuTemp {
  CPU_TEMP=$(cat /sys/class/thermal/thermal_zone0/temp)
  CPU_TEMP_I=$(($CPU_TEMP/1000))
  CPU_TEMP_D=$(($CPU_TEMP/100))
  CPU_TEMP_M=$(($CPU_TEMP_D % $CPU_TEMP_I))

  echo $CPU_TEMP_I.$CPU_TEMP_M
}

function cats {
  cputemp=`getCpuTemp`
  gputemp=`echo $(/opt/vc/bin/vcgencmd measure_temp) | grep -oE '[0-9][0-9].[0-9]'`

  watertemp=`/home/pi/bin/get_water_temp.sh | grep -oE '[0-9][0-9].[0-9]'`

  t8=`cat /home/pi/log/last_t8_status`
  co2=`cat /home/pi/log/last_co2_status`
  fan=`cat /home/pi/log/last_fan_step`
  leds=`cat /home/pi/log/last_night_leds_level`
}

function dweet {
  curl -d "status=Running" "http://dweet.io/dweet/for/piac" > /dev/null 2>&1
  curl -d "cpu-temp=$cputemp" "http://dweet.io/dweet/for/piac" > /dev/null 2>&1
  curl -d "gpu-temp=$gputemp" "http://dweet.io/dweet/for/piac" > /dev/null 2>&1
  curl -d "water-temp=$watertemp" "http://dweet.io/dweet/for/piac" > /dev/null 2>&1
  curl -d "t8-status=$t8" "http://dweet.io/dweet/for/piac" > /dev/null 2>&1
  curl -d "co2-status=$co2" "http://dweet.io/dweet/for/piac" > /dev/null 2>&1
  curl -d "lid-fan-step=$fan" "http://dweet.io/dweet/for/piac" > /dev/null 2>&1
  curl -d "night-leds-level=$leds" "http://dweet.io/dweet/for/piac" > /dev/null 2>&1
  curl -d "last-update=$(date +%T)" "http://dweet.io/dweet/for/piac" > /dev/null 2>&1
}

function dweet_off {
  curl -d "status=Sleeping" "http://dweet.io/dweet/for/piac" > /dev/null 2>&1
}

check_network

# Hour of the day
H=`date +%H`

# run only from 08:00 to 23:59
if [ "$H" -gt 7 ] && [ "$H" -lt 24 ]; then
  cats
  dweet
else
  dweet_off
fi
