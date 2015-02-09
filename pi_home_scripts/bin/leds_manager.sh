#!/bin/bash

if [ ! -f /tmp/piac_is_configured ]; then
  exit 0
fi

# This script name
SC=`basename $0`

# Debug false, more verbose
DEBUG=false

t8pin=18
co2pin=23
fanpin=25

TT="/home/pi/bin/leds_timetable"

h=( $(cat $TT | grep -v -e '^\s*$\|#' | tr -s ' ' | cut -d ' ' -f1  | cut -d ':' -f1) )
m=( $(cat $TT | grep -v -e '^\s*$\|#' | tr -s ' ' | cut -d ' ' -f1  | cut -d ':' -f2) )
for i in `echo ${!h[*]}`; do
  MINUTES[$i]=`echo "${h[$i]}*60+${m[$i]}" | bc`
done

# Get LED channells' levels
COLD=( $(cat $TT | grep -v -e '^\s*$\|#' | tr -s ' '  | cut -d ' ' -f2) )
WARM=( $(cat $TT | grep -v -e '^\s*$\|#' | tr -s ' '  | cut -d ' ' -f3) )
WHITE=( $(cat $TT | grep -v -e '^\s*$\|#' | tr -s ' '  | cut -d ' ' -f4) )
BLUE=( $(cat $TT | grep -v -e '^\s*$\|#' | tr -s ' '  | cut -d ' ' -f5) )

# Get CO2, LED fans and T8 status
CO2_STATUS=( $(cat $TT | grep -v -e '^\s*$\|#' | tr -s ' '  | cut -d ' ' -f6) )
FAN_STATUS=( $(cat $TT | grep -v -e '^\s*$\|#' | tr -s ' '  | cut -d ' ' -f7) )
T8_STATUS=( $(cat $TT | grep -v -e '^\s*$\|#' | tr -s ' '  | cut -d ' ' -f8) )

# For debug only
if [ "$DEBUG" = true ]; then echo -e "[$(date '+%x %X')] [$SC]* $TT entries:"; fi
if [ "$DEBUG" = true ]; then echo -e "[$(date '+%x %X')] [$SC]* ${MINUTES[@]}"; fi
if [ "$DEBUG" = true ]; then echo -e "[$(date '+%x %X')] [$SC]* ${COLD[@]}"; fi
if [ "$DEBUG" = true ]; then echo -e "[$(date '+%x %X')] [$SC]* ${WARM[@]}"; fi
if [ "$DEBUG" = true ]; then echo -e "[$(date '+%x %X')] [$SC]* ${WHITE[@]}"; fi
if [ "$DEBUG" = true ]; then echo -e "[$(date '+%x %X')] [$SC]* ${BLUE[@]}"; fi
if [ "$DEBUG" = true ]; then echo -e "[$(date '+%x %X')] [$SC]* ${CO2_STATUS[@]}"; fi
if [ "$DEBUG" = true ]; then echo -e "[$(date '+%x %X')] [$SC]* ${FAN_STATU[@]}"; fi
if [ "$DEBUG" = true ]; then echo -e "[$(date '+%x %X')] [$SC]* ${T8_STATUS[@]}"; fi

# Log file to store the last LED channels intensity level
COLD_LOG="/home/pi/log/last_leds_channel_cold_level"
if [ ! -f $COLD_LOG ]; then
  echo "0" > $COLD_LOG
  chmod 666 $COLD_LOG
fi
COLD_STORED=`cat $COLD_LOG`

WARM_LOG="/home/pi/log/last_leds_channel_warm_level"
if [ ! -f $WARM_LOG ]; then
  echo "0" > $WARM_LOG
  chmod 666 $WARM_LOG
fi
WARM_STORED=`cat $WARM_LOG`

WHITE_LOG="/home/pi/log/last_leds_channel_white_level"
if [ ! -f $WHITE_LOG ]; then
  echo "0" > $WHITE_LOG
  chmod 666 $WHITE_LOG
fi
WHITE_STORED=`cat $WHITE_LOG`

BLUE_LOG="/home/pi/log/last_leds_channel_blue_level"
if [ ! -f $BLUE_LOG ]; then
  echo "0" > $BLUE_LOG
  chmod 666 $BLUE_LOG
fi
BLUE_STORED=`cat $BLUE_LOG`

# Log file to store the last CO2 status
CO2_STATUS_LOG="/home/pi/log/last_co2_status"
if [ ! -f $CO2_STATUS_LOG ]; then
  echo "0" > $CO2_STATUS_LOG
  chmod 666 $CO2_STATUS_LOG
fi
STORED_CO2_STATUS=`cat $CO2_STATUS_LOG`

# Log file to store the last LED fan status
FAN_STATUS_LOG="/home/pi/log/last_led_cooling_status"
if [ ! -f $FAN_STATUS_LOG ]; then
  echo "0" > $FAN_STATUS_LOG
  chmod 666 $FAN_STATUS_LOG
fi
STORED_FAN_STATUS=`cat $FAN_STATUS_LOG`

# Log file to store the last T8 lamps status
T8_STATUS_LOG="/home/pi/log/last_t8_status"
if [ ! -f $T8_STATUS_LOG ]; then
  echo "0" > $T8_STATUS_LOG
  chmod 666 $T8_STATUS_LOG
fi
STORED_T8_STATUS=`cat $T8_STATUS_LOG`

# Define the function to switch CO2 electrovalve on/off
function writeCo2gpioPin {
  if [ "$1" != "$STORED_CO2_STATUS" ]; then
    if [ "$DEBUG" = true ]; then echo "[$(date '+%x %X')] [$SC]* Stored CO2 power status: $STORED_CO2_STATUS"; fi

    # CO2 gpio pin
    gpio -g write $co2pin $1
    if [ "$?" -ne 0 ]; then
      echo "[$(date '+%x %X')] [$SC] Failed. Trying another time $1"
      gpio export $co2pin out
      gpio -g write $co2pin $1
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

function writeFanGpioPin {
  if [ "$1" != "$STORED_FAN_STATUS" ]; then
    if [ "$DEBUG" = true ]; then echo "[$(date '+%x %X')] [$SC]* Stored CO2 power status: $STORED_FAN_STATUS"; fi

    # LED fan gpio pin
    gpio -g write $fanpin $1
    if [ "$?" -ne 0 ]; then
      echo "[$(date '+%x %X')] [$SC] Failed. Trying another time $1"
      gpio export $fanpin out
      gpio -g write $fanpin $1
      if [ "$?" -ne 0 ]; then
        echo $1 > $FAN_STATUS_LOG
        echo "[$(date '+%x %X')] [$SC] Switching LED fan to status $1"
      fi
    else
      echo $1 > $FAN_STATUS_LOG
      echo "[$(date '+%x %X')] [$SC] Switching LED fan to status $1"
    fi

    sleep 1
  fi
}

function writeT8GpioPin {
  if [ "$1" != "$STORED_T8_STATUS" ]; then
    if [ "$DEBUG" = true ]; then echo "[$(date '+%x %X')] [$SC]* Stored CO2 power status: $STORED_T8_STATUS"; fi

    # T8 lamps gpio pin
    gpio -g write $t8pin $1
    if [ "$?" -ne 0 ]; then
      echo "[$(date '+%x %X')] [$SC] Failed. Trying another time $1"
      gpio export $t8pin out
      gpio -g write $t8pin $1
      if [ "$?" -ne 0 ]; then
        echo $1 > $T8_STATUS_LOG
        echo "[$(date '+%x %X')] [$SC] Switching T8 lamps to status $1"
      fi
    else
      echo $1 > $T8_STATUS_LOG
      echo "[$(date '+%x %X')] [$SC] Switching T8 lamps to status $1"
    fi

    sleep 1
  fi
}

# Extrapolate values between defined times and values in TT
function interpolate {
  x1=$1
  y1=$2
  x2=$3
  y2=$4

  M=$5

  BC=`echo -e "scale=1;
               x1=$x1;
               y1=$y1;
               x2=$x2;
               y2=$y2;
               x=$M; print (x-x1)*(y2-y1)/(x2-x1)+y1" | bc | sed 's/^\./0./'`
  echo $BC
}

# Define the function to send the servoblaster command
function callServoblaster {
  STORED_LEVEL=$(eval "echo \$$3_STORED")
  CHANNEL_LOG=$(eval "echo \$$3_LOG")

  if [ "$1" != "$STORED_LEVEL" ]; then
    if [ "$DEBUG" = true ]; then echo "[$(date '+%x %X')] [$SC]* Stored $3 channell: $STORED_LEVEL"; fi
    #if [ "$DEBUG" = true ]; then echo "[$(date '+%x %X')] [$SC]* Setting $3 channell to $1%"; fi
    echo "[$(date '+%x %X')] [$SC] Setting $3 channell to $1%"

    if [ "$1" != 0 ]; then
      val="$1%"
    else
      val="$1"
    fi

    echo "$2"="$val" > /dev/servoblaster
    if [ "$?" -ne 0 ]; then
      echo "[$(date '+%x %X')] [$SC] Setting $3 channell failed. Exiting"
      exit 1
    else
      echo $1 > $CHANNEL_LOG
    fi

  fi
}

# Current day minute through all the day [ranges from 0 to 1439, minutes n° 1 to n° 1440=(24h*60min)]
#M=$1 # for development test
M=$(echo "`date +%k`*60+`date +%M`" | bc)
if [ "$DEBUG" = true ]; then echo "[$(date '+%x %X')] [$SC]* Current day minute is $M"; fi
if [ $M -eq 1439 ]; then echo "[$(date '+%x %X')] [$SC]... End of day ..." && exit 0; fi

for i in `echo ${!MINUTES[*]}`; do
  x1=${MINUTES[$i]}
  x2=${MINUTES[$(( $i+1 ))]}

  if [[ "$M" -eq "$x1"  ||  "$M" -gt "$x1"  &&  "$M" -lt "$x2" ]]; then

    cold_y1=${COLD[$i]}
    cold_y2=${COLD[$(( $i+1 ))]}

    cold_value=`interpolate $x1 $cold_y1 $x2 $cold_y2 $M`

    warm_y1=${WARM[$i]}
    warm_y2=${WARM[$(( $i+1 ))]}

    warm_value=`interpolate $x1 $warm_y1 $x2 $warm_y2 $M`

    white_y1=${WHITE[$i]}
    white_y2=${WHITE[$(( $i+1 ))]}

    white_value=`interpolate $x1 $white_y1 $x2 $white_y2 $M`

    blue_y1=${BLUE[$i]}
    blue_y2=${BLUE[$(( $i+1 ))]}

    blue_value=`interpolate $x1 $blue_y1 $x2 $blue_y2 $M`

    callServoblaster $cold_value 2 COLD
    callServoblaster $warm_value 3 WARM
    callServoblaster $white_value 4 WHITE
    callServoblaster $blue_value 0 BLUE

    #echo "[$(date '+%x %X')] [$SC] COLD:$cold_value / WARM:$warm_value / WHITE:$white_value / BLUE:$blue_value"

    co2=${CO2_STATUS[$i]}
    writeCo2gpioPin $co2

    coolingFan=${FAN_STATUS[$i]}
    writeFanGpioPin $coolingFan

    t8Lamps=${T8_STATUS[$i]}
    writeT8GpioPin $t8Lamps

    exit 0

  fi

done
