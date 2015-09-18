#!/bin/bash

# This script name
SC=`basename $0`

function check_network {
  ping -c 1 -w 3 8.8.8.8 > /dev/null 2>&1
  if [ "$?" -ne 0 ]; then
    exit 1
  fi
}

function cats {
  cputemp=`/home/pi/bin/get_temp.sh cpu`
  gputemp=`/home/pi/bin/get_temp.sh gpu`
  watertemp=`/home/pi/bin/get_temp.sh water`
  casetemp=`/home/pi/bin/get_temp.sh case`
  co2=`cat /home/pi/log/last_co2_status`
  fan=`cat /home/pi/log/last_fan_step`

  cold=`cat /home/pi/log/last_leds_channel_cold_level`
  warm=`cat /home/pi/log/last_leds_channel_warm_level`
  white=`cat /home/pi/log/last_leds_channel_white_level`
  blue=`cat /home/pi/log/last_leds_channel_blue_level`
}

function dweet {
  curl -d "status=Running" "http://dweet.io/dweet/for/piac" > /dev/null 2>&1

  curl -d "cpu-temp=$cputemp" "http://dweet.io/dweet/for/piac" > /dev/null 2>&1
  curl -d "gpu-temp=$gputemp" "http://dweet.io/dweet/for/piac" > /dev/null 2>&1
  curl -d "water-temp=$watertemp" "http://dweet.io/dweet/for/piac" > /dev/null 2>&1
  curl -d "case-temp=$casetemp" "http://dweet.io/dweet/for/piac" > /dev/null 2>&1
  curl -d "co2-status=$co2" "http://dweet.io/dweet/for/piac" > /dev/null 2>&1
  curl -d "lid-fan-step=$fan" "http://dweet.io/dweet/for/piac" > /dev/null 2>&1

  curl -d "leds_channel_cold_level=$cold" "http://dweet.io/dweet/for/piac" > /dev/null 2>&1
  curl -d "leds_channel_warm_level=$warm" "http://dweet.io/dweet/for/piac" > /dev/null 2>&1
  curl -d "leds_channel_white_level=$white" "http://dweet.io/dweet/for/piac" > /dev/null 2>&1
  curl -d "leds_channel_blue_level=$blue" "http://dweet.io/dweet/for/piac" > /dev/null 2>&1

  curl -d "last-update=$(date +%T)" "http://dweet.io/dweet/for/piac" > /dev/null 2>&1
}

function dweet_off {
  curl -d "status=Sleeping" "http://dweet.io/dweet/for/piac" > /dev/null 2>&1
  curl -d "last-update=$(date +%T)" "http://dweet.io/dweet/for/piac" > /dev/null 2>&1
}

check_network

# Hour of the day
H=`date +%H`

# run only from 06:00 to 21:59 UTC
if [ "$H" -gt 5 ] && [ "$H" -lt 22 ]; then
  cats
  dweet
else
  dweet_off
fi
