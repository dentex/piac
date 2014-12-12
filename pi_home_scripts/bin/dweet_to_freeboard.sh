#!/bin/bash

# This script name
SC=`basename $0`

function check_network {
  ping -c 1 -w 3 google.it > /dev/null 2>&1
  if [ "$?" -ne 0 ]; then
    exit 1
  fi
}

function cats {
  cputemp=`/home/pi/bin/get_temp.sh cpu`
  gputemp=`/home/pi/bin/get_temp.sh gpu`
  watertemp=`/home/pi/bin/get_temp.sh water`
  casetemp=`/home/pi/bin/get_temp.sh case`
  t8=`cat /home/pi/log/last_t8_status`
  co2=`cat /home/pi/log/last_co2_status`
  fan=`cat /home/pi/log/last_fan_step`
  leds=`cat /home/pi/log/last_night_leds_level`
}

function dweet {
  curl -d "status=Running" "http://dweet.io/dweet/for/piac" > /dev/null 2>&1
  curl -d "cpu-temp=$cputemp" "http://dweet.io/dweet/for/piac" > /dev/null 2>&1
  curl -d "gpu-temp=$gputemp" "http://dweet.io/dweet/for/piac" > /dev/null 2>&1
  curl -d "case-temp=$casetemp" "http://dweet.io/dweet/for/piac" > /dev/null 2>&1
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

# run only from 07:00 to 23:59
if [ "$H" -gt 6 ] && [ "$H" -lt 24 ]; then
  cats
  dweet
else
  dweet_off
fi
