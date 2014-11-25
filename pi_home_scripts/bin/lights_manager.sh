#!/bin/bash

# This script name
SC=`basename $0`

# Debug flag, more verbose
DEBUG=false

# Timetable file
TT="/home/pi/bin/lights_timetable"

h=( $(cat $TT | grep -v -e '^\s*$\|#' | cut -d ' ' -f1 | cut -d ':' -f1) )
m=( $(cat $TT | grep -v -e '^\s*$\|#' | cut -d ' ' -f1 | cut -d ':' -f2) )
for i in `echo ${!h[*]}`; do
  MINUTES[$i]=`echo "${h[$i]}*60+${m[$i]}" | bc`
done

# Get T8 status (1 -> ON; 0 -> OFF)
T8_STATUS=( $(cat $TT | grep -v -e '^\s*$\|#' | cut -d ' ' -f2) )

# Get CO2 status (1 -> ON; 0 -> OFF)
CO2_STATUS=( $(cat $TT | grep -v -e '^\s*$\|#' | cut -d ' ' -f3) )

# Get night LEDs' levels at every minute from the time table
LEDS_LEVEL=( $(cat $TT | grep -v -e '^\s*$\|#' | cut -d ' ' -f4) )

# For debug only
if [ "$DEBUG" = true ]; then echo -e "[$(date '+%x %X')] [$SC]* $TT entries:"; fi
if [ "$DEBUG" = true ]; then echo -e "[$(date '+%x %X')] [$SC]* ${MINUTES[@]}"; fi
if [ "$DEBUG" = true ]; then echo -e "[$(date '+%x %X')] [$SC]* ${LEDS_LEVEL[@]}"; fi
if [ "$DEBUG" = true ]; then echo -e "[$(date '+%x %X')] [$SC]* ${T8_STATUS[@]}"; fi
if [ "$DEBUG" = true ]; then echo -e "[$(date '+%x %X')] [$SC]* ${CO2_STATUS[@]}"; fi

# Log file to store the last LEDs intensity level
LED_LEVEL_LOG="/home/pi/log/last_night_leds_level"
if [ ! -f $LED_LEVEL_LOG ]; then
  echo "0" > $LED_LEVEL_LOG
  chmod 666 $LED_LEVEL_LOG
fi
STORED_LEDS_LEVEL=`cat $LED_LEVEL_LOG`

# Log file to store the last T8 lamps power status
T8_STATUS_LOG="/home/pi/log/last_t8_status"
if [ ! -f $T8_STATUS_LOG ]; then
  echo "0" > $T8_STATUS_LOG
  chmod 666 $T8_STATUS_LOG
fi
STORED_T8_STATUS=`cat $T8_STATUS_LOG`

# Log file to store the last CO2 lamps power status
CO2_STATUS_LOG="/home/pi/log/last_co2_status"
if [ ! -f $CO2_STATUS_LOG ]; then
  echo "0" > $CO2_STATUS_LOG
  chmod 666 $CO2_STATUS_LOG
fi
STORED_CO2_STATUS=`cat $CO2_STATUS_LOG`

# Some FUNCTIONS

# Define the function to get a given timetable's minute index in its array
function echoMinuteIndex {
  for i in `echo ${!MINUTES[*]}`; do
    elem=${MINUTES[$i]};
    if [ "$elem" -eq "$1" ]; then
      echo $i
    fi
  done
}

# Define the function to switch T8 lamps on/off
function writeT8gpioPin {
  if [ "$1" != "$STORED_T8_STATUS" ]; then
    if [ "$DEBUG" = true ]; then echo "[$(date '+%x %X')] [$SC]* Stored T8 power status: $STORED_T8_STATUS"; fi

    # T8 gpio pin
    gpio -g write 18 $1
    if [ "$?" -ne 0 ]; then
      gpio export 18 out
      gpio -g write 18 $1
      if [ "$?" -ne 0 ]; then
        echo $1 > $T8_STATUS_LOG
        echo "[$(date '+%x %X')] [$SC] Switching T8 to status $1"
      fi
    else
      echo $1 > $T8_STATUS_LOG
      echo "[$(date '+%x %X')] [$SC] Switching T8 to status $1"
    fi

    sleep 1
  fi
}

# Define the function to switch CO2 electrovalve on/off
function writeCo2gpioPin {
  if [ "$1" != "$STORED_CO2_STATUS" ]; then
    if [ "$DEBUG" = true ]; then echo "[$(date '+%x %X')] [$SC]* Stored CO2 power status: $STORED_CO2_STATUS"; fi

    # CO2 gpio pin
    gpio -g write 24 $1
    if [ "$?" -ne 0 ]; then
      echo "[$(date '+%x %X')] [$SC] Failed. Trying another time $1"
      gpio export 24 out
      gpio -g write 24 $1
      if [ "$?" -ne 0 ]; then
        echo $1 > $CO2_STATUS_LOG
        echo "[$(date '+%x %X')] [$SC] Switching CO2 to status $1"
      fi
    else
      echo $1 > $CO2_STATUS_LOG
      echo "[$(date '+%x %X')] [$SC] Switching CO2 to status $1"
    fi

    sleep 1
  fi
}

# Define the function to send the servoblaster command
function callServoblaster {
  if [ "$1" != "$STORED_LEDS_LEVEL" ]; then
    if [ "$DEBUG" = true ]; then echo "[$(date '+%x %X')] [$SC]* Stored LEDs intensity value: $STORED_LEDS_LEVEL"; fi
    echo "[$(date '+%x %X')] [$SC] Setting night LEDs intensity to $1%"

    if [ "$1" -eq 0 ]; then
      val="$1"
    else
      val="$1%"
    fi

    echo 0="$val" > /dev/servoblaster
    if [ "$?" -ne 0 ]; then
      echo "[$(date '+%x %X')] [$SC] Setting night LEDs intensity failed. Exiting"
      exit 1
    else
      echo $1 > $LED_LEVEL_LOG
    fi

  fi
}

# Current day minute through all the day [ranges from 0 to 1439, minutes n° 1 to n° 1440=(24h*60min)]
#M=$1 # for development test
M=$(echo "`date +%k`*60+`date +%M`" | bc)
if [ "$DEBUG" = true ]; then echo "[$(date '+%x %X')] [$SC]* Current day minute is $M"; fi

# Initially check if $M is exactly one minute from the timetable and set LEDs intensity/T8/CO2 status accordingly
for ttm in `echo ${MINUTES[@]}`; do

  if [ "$M" -eq "$ttm" ]; then

    # Check T8/CO2 status and LEDs intensity
    index=`echoMinuteIndex $M`
    T=${T8_STATUS[$index]}
    C=${CO2_STATUS[$index]}
    L=${LEDS_LEVEL[$index]}
    if [ "$DEBUG" = true ]; then echo "[$(date '+%x %X')] [$SC]* Minute $M's exact index is $index, with level $L"; fi

    writeT8gpioPin $T
    writeCo2gpioPin $C
    callServoblaster $L

    exit 0

  fi

done

# Extrapolate night LEDs' intensity values falling between defined times/levels in $TT
# Set the T8/CO2 power status according to the last value written in $TT
for i in `echo ${!MINUTES[*]}`; do
  x1=${MINUTES[$i]}
  x2=${MINUTES[$(( $i+1 ))]}

  if [ "$M" -gt "$x1" ] && [ "$M" -lt "$x2" ]; then

    y1=${LEDS_LEVEL[$i]}
    y2=${LEDS_LEVEL[$(( $i+1 ))]}

    BC_L=`echo -e "x1=$x1;
                y1=$y1;
                x2=$x2;
                y2=$y2;
                x=$M; print (x-x1)*(y2-y1)/(x2-x1)+y1" | bc`

    if [ "$DEBUG" = true ]; then echo "[$(date '+%x %X')] [$SC]* Minute $M's LEDs side-values ($x1,$y1); ($x2,$y2). Extrapolated level $BC_L"; fi
    callServoblaster $BC_L

    t8=${T8_STATUS[$i]}
    if [ "$DEBUG" = true ]; then echo "[$(date '+%x %X')] [$SC]* Minute $M's T8 left-side-value $t8"; fi
    writeT8gpioPin $t8

    co2=${CO2_STATUS[$i]}
    if [ "$DEBUG" = true ]; then echo "[$(date '+%x %X')] [$SC]* Minute $M's CO2 left-side-value $co2"; fi
    writeCo2gpioPin $co2

    exit 0

  fi

done
