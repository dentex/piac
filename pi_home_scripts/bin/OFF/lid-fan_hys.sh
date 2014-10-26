#!/bin/bash

# This script name
SC=`basename $0`

# Debug flag, more verbose
DEBUG=true

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
qi=5

if [ "$1" == "quiter" ]; then
  P=$1

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

STEP_1_R="50%"
STEP_2_R="60%"
STEP_3_R="70%"
STEP_4_R="80%"
STEP_5_R="90%"
STEP_6_R="100%"

# Use 1°C of hysteresis
HYS="1"

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

# Log file to store the last temperature
TEMP_LOG="/home/pi/log/last_temp"
if [ ! -f $TEMP_LOG ]; then
  touch $TEMP_LOG
  chmod 666 $TEMP_LOG
  STORED_TEMP="0"
else
  STORED_TEMP=`cat $TEMP_LOG`
fi
if [ "$DEBUG" = true ]; then echo -e "\n[$(date '+%x %X')] [$SC]* stored temp $STORED_TEMP"; fi

# Log file to store the last used fan speed step
FAN_STEP_LOG="/home/pi/log/last_fan_step"
if [ ! -f $FAN_STEP_LOG ]; then
  touch $FAN_STEP_LOG
  chmod 666 $FAN_STEP_LOG
  STORED_SPEED="0"
else
  STORED_SPEED=`cat $FAN_STEP_LOG`
fi
if [ "$DEBUG" = true ]; then echo -e "\n[$(date '+%x %X')] [$SC]* stored speed $STORED_SPEED"; fi

# Define two functions to decide fan speed with the two hysteresis "directions" up...
function check_fan_speed_hysteresis_up {
  if [ "$CPU_TEMP_I" -gt "$(($STEP_6_T+$HYS))" ]; then
    CURR_SPEED=$STEP_6_R
  elif [ "$CPU_TEMP_I" -gt "$(($STEP_5_T+$HYS))" ]; then
    CURR_SPEED=$STEP_5_R
  elif [ "$CPU_TEMP_I" -gt "$(($STEP_4_T+$HYS))" ]; then
    CURR_SPEED=$STEP_4_R
  elif [ "$CPU_TEMP_I" -gt "$(($STEP_3_T+$HYS))" ]; then
    CURR_SPEED=$STEP_3_R
  elif [ "$CPU_TEMP_I" -gt "$(($STEP_2_T+$HYS))" ]; then
    CURR_SPEED=$STEP_2_R
  elif [ "$CPU_TEMP_I" -gt "$(($STEP_1_T+$HYS))" ]; then
    CURR_SPEED=$STEP_1_R
  else
    CURR_SPEED=$STEP_0_R
  fi
}

# ...and down
function check_fan_speed_hysteresis_down {
  if [ "$CPU_TEMP_I" -gt "$(($STEP_6_T-$HYS))" ]; then
    CURR_SPEED=$STEP_6_R
  elif [ "$CPU_TEMP_I" -gt "$(($STEP_5_T-$HYS))" ]; then
    CURR_SPEED=$STEP_5_R
  elif [ "$CPU_TEMP_I" -gt "$(($STEP_4_T-$HYS))" ]; then
    CURR_SPEED=$STEP_4_R
  elif [ "$CPU_TEMP_I" -gt "$(($STEP_3_T-$HYS))" ]; then
    CURR_SPEED=$STEP_3_R
  elif [ "$CPU_TEMP_I" -gt "$(($STEP_2_T-$HYS))" ]; then
    CURR_SPEED=$STEP_2_R
  elif [ "$CPU_TEMP_I" -gt "$(($STEP_1_T-$HYS))" ]; then
    CURR_SPEED=$STEP_1_R
  else
    CURR_SPEED=$STEP_0_R
  fi
}

# Define the function to actually change the fan speed
function change_fan_speed {
  echo "[$(date '+%x %X')] [$SC] CPU temp is $CPU_TEMP_I.$CPU_TEMP_M°C"

  echo "[$(date '+%x %X')] [$SC] Setting lid fan speed to $CURR_SPEED"
  echo 1=$CURR_SPEED > /dev/servoblaster
  echo $CURR_SPEED > $FAN_STEP_LOG
}

# Choose the appropriate hysteresis "direction"
if [ "$STORED_TEMP" -lt "$CPU_TEMP" ]; then
  if [ "$DEBUG" = true ]; then echo "[$SC]* hysteresis_up, current temp $CPU_TEMP"; fi
  check_fan_speed_hysteresis_up
else
  if [ "$DEBUG" = true ]; then echo "[$SC]* hysteresis_down, current temp $CPU_TEMP"; fi
  check_fan_speed_hysteresis_down
fi
echo $CPU_TEMP > $TEMP_LOG

if [ "$DEBUG" = true ]; then echo "[$(date '+%x %X')] [$SC]* current speed $CURR_SPEED"; fi
if [ "$CURR_SPEED" != "$STORED_SPEED" ]; then
  change_fan_speed
fi
