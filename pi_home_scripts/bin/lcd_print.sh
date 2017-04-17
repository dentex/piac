#!/bin/bash

# This script name
SC=`basename $0`

# LCD delay between *pages*
t=3

user_interrupt(){
  echo -e "\n\nKeyboard Interrupt detected."
  sleep 1
  /home/pi/bin/lcd_turn_backlight_off.py
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
    lidfan=`cat /home/pi/log/last_fan_step 2>/dev/null`
    if [ "$lidfan" == "" ]; then
      lidfan="-"
    fi

    watertemp=`/home/pi/bin/get_temp.sh water`
    co2raw=`cat /home/pi/log/last_co2_status 2>/dev/null`
    if [ "$co2raw" != "" ]; then
      if [ "$co2raw" -eq 1 ]; then
        co2=ON
      else
        co2=OFF
      fi
    else
      co2="-"
    fi

    white=`cat /home/pi/log/last_leds_channel_white_level 2>/dev/null`
    warm=`cat /home/pi/log/last_leds_channel_warm_level 2>/dev/null`

    cold=`cat /home/pi/log/last_leds_channel_cold_level 2>/dev/null`
    blue=`cat /home/pi/log/last_leds_channel_blue_level 2>/dev/null`
  fi
}

function print {
  /home/pi/bin/lcd_print.py -x "CPU Temp: $cputemp" -y "GPU Temp: $gputemp   "
  sleep $t
  /home/pi/bin/lcd_print.py -x "Case Temp: $casetemp" -y "Lid  Fan:  $lidfan%    "
  sleep $t
  /home/pi/bin/lcd_print.py -x "Water Temp: $watertemp" -y "CO2  Valve: $co2         "
  sleep $t
  /home/pi/bin/lcd_print.py -x "White Ch: $white%" -y "Warm  Ch: $warm%    "
  sleep $t
  /home/pi/bin/lcd_print.py -x "Cold Ch: $cold%" -y "Blue Ch: $blue%   "
  sleep $t

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
    fi
    sleep 600
  fi
done
