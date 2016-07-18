#!/bin/bash

# This script name
SC=`basename $0`

user_interrupt(){
  echo -e "\n\nKeyboard Interrupt detected."
  sleep 1
  /home/pi/bin/lcd_reset.py
  exit 0
}

trap user_interrupt SIGINT
trap user_interrupt SIGTSTP

IS_LCD_ON=false

function cats {
  if [ -f /tmp/piac_is_configured ]; then
    cputemp=`/home/pi/bin/get_temp.sh cpu`
    gputemp=`/home/pi/bin/get_temp.sh gpu`

    casetemp=`/home/pi/bin/get_temp.sh case`
    lidfan=`cat /home/pi/log/last_fan_step`

    watertemp=`/home/pi/bin/get_temp.sh water`
    co2raw=`cat /home/pi/log/last_co2_status`
    if [ "$co2raw" -eq 1 ]; then 
      co2=ON
    else
      co2=OFF
    fi

    white=`cat /home/pi/log/last_leds_channel_white_level`
    warm=`cat /home/pi/log/last_leds_channel_warm_level`

    cold=`cat /home/pi/log/last_leds_channel_cold_level`
    blue=`cat /home/pi/log/last_leds_channel_blue_level`
  fi
}

function print {
  /home/pi/bin/lcd_print.py -a "CPU Temp: $cputemp" -b "GPU Temp: $gputemp   "
  /home/pi/bin/lcd_print.py -a "Case Temp: $casetemp" -b "Lid  Fan:  $lidfan%    "
  /home/pi/bin/lcd_print.py -a "Water Temp: $watertemp" -b "CO2  Valve: $co2         "
  /home/pi/bin/lcd_print.py -a "White Ch: $white%" -b "Warm  Ch: $warm%    "
  /home/pi/bin/lcd_print.py -a "Cold Ch: $cold%" -b "Blue Ch: $blue%   "

  #if [ "$?" -eq 0 ]; then
    IS_LCD_ON=true
  #fi
}

while : 
do
  # Hour of the day
  H=`date +%H`

  # run only from 04:00 to 18:59 UTC
  if [ "$H" -gt 3 ] && [ "$H" -lt 19 ]; then
    cats
    print
  else
    if [ "$IS_LCD_ON" = true ]; then
      /home/pi/bin/lcd_turn_backlight_off.py
      IS_LCD_ON=false
      sleep 300
    fi
  fi
done
