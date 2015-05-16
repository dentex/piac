#!/bin/bash

if [ ! -f /tmp/piac_is_configured ]; then
  exit 0
fi

# This script name
SC=`basename $0`

# Debug flag, more verbose
DEBUG=false

# Max temperature allowed
MAX_T="75"

# Temperature steps - 'normal' profile
STEP_1_T="39"
STEP_2_T="44"
STEP_3_T="49"
STEP_4_T="54"
STEP_5_T="59"
STEP_6_T="64"

# Default profile
P="normal"

# Quiter profile temperature steps increment
qi=2

# Hour of the day
H=`date +%H`

# 'quiter' when time goes from 20:00 to 23:59 UTC
if [ "$H" -gt 19 ] && [ "$H" -lt 24 ]; then
  P="quiter"
  # Temperature steps - 'quiter' profile
  let STEP_1_T=STEP_1_T+$qi
  let STEP_2_T=STEP_2_T+$qi
  let STEP_3_T=STEP_3_T+$qi
  let STEP_4_T=STEP_4_T+$qi
  let STEP_5_T=STEP_5_T+$qi
  let STEP_6_T=STEP_6_T+$qi
fi

# Lid fan speed steps
STEP_0_R="0"

STEP_1_R="50"
STEP_2_R="60"
STEP_3_R="70"
STEP_4_R="80"
STEP_5_R="90"
STEP_6_R="100"

# Retrieve SoC temperature
CPU_TEMP=$(cat /sys/class/thermal/thermal_zone0/temp)
CPU_TEMP_I=$(($CPU_TEMP/1000))
CPU_TEMP_D=$(($CPU_TEMP/100))
CPU_TEMP_M=$(($CPU_TEMP_D % $CPU_TEMP_I))

# Check if temperature is too high and halt the system
if [ "$CPU_TEMP_I" -gt "$MAX_T" ]; then
  echo "[$(date '+%x %X')] [$SC] SoC temperature is too high. Shutting system down."
  /usr/bin/logger "CPU temp is $CPU_TEMP_I - Shutting system down."
  /sbin/shutdown -h now
  exit 0
fi

# Log file to store the last used fan speed step
FAN_STEP_LOG="/home/pi/log/last_fan_step"
if [ ! -f $FAN_STEP_LOG ]; then
  echo "0" > $FAN_STEP_LOG
  chmod 666 $FAN_STEP_LOG
fi
STORED_SPEED=`cat $FAN_STEP_LOG`

if [ "$DEBUG" = true ]; then echo -e "\n[$(date '+%x %X')] [$SC]* stored speed $STORED_SPEED"; fi

# Define the function to decide fan speed
function check_fan_speed {
  if [ "$CPU_TEMP_I" -gt "$STEP_6_T" ]; then
    CURR_SPEED=$STEP_6_R
  elif [ "$CPU_TEMP_I" -gt "$STEP_5_T" ]; then
    CURR_SPEED=$STEP_5_R
  elif [ "$CPU_TEMP_I" -gt "$STEP_4_T" ]; then
    CURR_SPEED=$STEP_4_R
  elif [ "$CPU_TEMP_I" -gt "$STEP_3_T" ]; then
    CURR_SPEED=$STEP_3_R
  elif [ "$CPU_TEMP_I" -gt "$STEP_2_T" ]; then
    CURR_SPEED=$STEP_2_R
  elif [ "$CPU_TEMP_I" -gt "$STEP_1_T" ]; then
    CURR_SPEED=$STEP_1_R
  else
    CURR_SPEED=$STEP_0_R
  fi
}

# Define the function to actually change the fan speed
function change_fan_speed {
  echo "[$(date '+%x %X')] [$SC] CPU temp is $CPU_TEMP_I.$CPU_TEMP_M°C"
  echo "[$(date '+%x %X')] [$SC] [$P profile] Setting lid fan speed to $CURR_SPEED"

  if [ "$CURR_SPEED" -eq 0 ]; then
    val="$CURR_SPEED"
  else
    val="$CURR_SPEED%"
  fi

  echo 1="$val" > /dev/servoblaster

  if [ "$?" -eq 0 ]; then
    echo $CURR_SPEED > $FAN_STEP_LOG
  else
    echo "[$(date '+%x %X')] [$SC] [$P profile] Failed."
  fi
}

check_fan_speed

if [ "$DEBUG" = true ]; then echo "[$(date '+%x %X')] [$SC]* current speed $CURR_SPEED"; fi
if [ "$CURR_SPEED" != "$STORED_SPEED" ]; then
  change_fan_speed
fi
