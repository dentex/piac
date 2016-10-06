#!/bin/bash

# This script name
SC=`basename $0`

if [ ! -f /tmp/piac_is_configured ]; then
  if [ "$1" != "force" ]; then
    #echo -e "[$(date '+%x %X')] [$SC] PiAC is not configured: exiting."
    exit 1
  else 
    echo "*** PiAC is not configured, but using \"force\" option ***"
  fi
fi

# Debug true => more verbose
DEBUG=false

# Current day minute through all the day [ranges from 0 to 1439, minutes n° 1 to n° 1440=(24h*60min)]
#M=$1 # for development test
M=$(echo "`date +%H`*60+`date +%M`" | bc)
if [ "$DEBUG" = true ]; then echo "[$(date '+%x %X')] [$SC]* Current day minute is $M"; fi
if [ $M -eq 1439 ]; then
  echo "[$(date '+%x %X')] [$SC]... End of day ..."
  echo "========================================================="
  exit 0
fi

# exit between 22:00 and 03:00 UTC (due to "flat" LED's timetable)
if [ "$M" -gt 1320 ] || [ "$M" -lt 180 ]; then
  exit 2
fi

# GPIO pins in use
# unused=18
co2pin=23
fanpin=24
potpin=25

TT="/home/pi/bin/leds_timetable"

h=( $(cat $TT | grep -v -e '^\s*$\|#' | tr -s ' ' | cut -d ' ' -f1  | cut -d ':' -f1) )
m=( $(cat $TT | grep -v -e '^\s*$\|#' | tr -s ' ' | cut -d ' ' -f1  | cut -d ':' -f2) )
for i in `echo ${!h[*]}`; do
  MINUTES[$i]=`echo "${h[$i]}*60+${m[$i]}" | bc`
done

# Get LED channells' PWM levels (AUX_A for the mini-paludarium)
COLD=( $(cat $TT | grep -v -e '^\s*$\|#' | tr -s ' '  | cut -d ' ' -f2) )
WARM=( $(cat $TT | grep -v -e '^\s*$\|#' | tr -s ' '  | cut -d ' ' -f3) )
WHITE=( $(cat $TT | grep -v -e '^\s*$\|#' | tr -s ' '  | cut -d ' ' -f4) )
BLUE=( $(cat $TT | grep -v -e '^\s*$\|#' | tr -s ' '  | cut -d ' ' -f5) )
AUX_A=( $(cat $TT | grep -v -e '^\s*$\|#' | tr -s ' '  | cut -d ' ' -f8) )

# Get CO2, LED fans and AUX_B (test-bowls) statuses
CO2_STATUS=( $(cat $TT | grep -v -e '^\s*$\|#' | tr -s ' '  | cut -d ' ' -f6) )
FAN_STATUS=( $(cat $TT | grep -v -e '^\s*$\|#' | tr -s ' '  | cut -d ' ' -f7) )
AUX_B_STATUS=( $(cat $TT | grep -v -e '^\s*$\|#' | tr -s ' '  | cut -d ' ' -f9) )

# For debug only
if [ "$DEBUG" = true ]; then echo -e "[$(date '+%x %X')] [$SC]* $TT entries:"; fi
if [ "$DEBUG" = true ]; then echo -e "[$(date '+%x %X')] [$SC]* ${MINUTES[@]}"; fi
if [ "$DEBUG" = true ]; then echo -e "[$(date '+%x %X')] [$SC]* ${COLD[@]}"; fi
if [ "$DEBUG" = true ]; then echo -e "[$(date '+%x %X')] [$SC]* ${WARM[@]}"; fi
if [ "$DEBUG" = true ]; then echo -e "[$(date '+%x %X')] [$SC]* ${WHITE[@]}"; fi
if [ "$DEBUG" = true ]; then echo -e "[$(date '+%x %X')] [$SC]* ${BLUE[@]}"; fi
if [ "$DEBUG" = true ]; then echo -e "[$(date '+%x %X')] [$SC]* ${CO2_STATUS[@]}"; fi
if [ "$DEBUG" = true ]; then echo -e "[$(date '+%x %X')] [$SC]* ${FAN_STATUS[@]}"; fi
if [ "$DEBUG" = true ]; then echo -e "[$(date '+%x %X')] [$SC]* ${AUX_A[@]}"; fi
if [ "$DEBUG" = true ]; then echo -e "[$(date '+%x %X')] [$SC]* ${AUX_B_STATUS[@]}"; fi

# Log files to store the last LED channels PWM levels
COLD_LOG="/home/pi/log/last_leds_channel_cold_level"
if [ ! -f $COLD_LOG ]; then
  echo "0" > $COLD_LOG
  chmod 666 $COLD_LOG
fi
COLD_STORED=`cat $COLD_LOG 2>/dev/null`

WARM_LOG="/home/pi/log/last_leds_channel_warm_level"
if [ ! -f $WARM_LOG ]; then
  echo "0" > $WARM_LOG
  chmod 666 $WARM_LOG
fi
WARM_STORED=`cat $WARM_LOG 2>/dev/null`

WHITE_LOG="/home/pi/log/last_leds_channel_white_level"
if [ ! -f $WHITE_LOG ]; then
  echo "0" > $WHITE_LOG
  chmod 666 $WHITE_LOG
fi
WHITE_STORED=`cat $WHITE_LOG 2>/dev/null`

BLUE_LOG="/home/pi/log/last_leds_channel_blue_level"
if [ ! -f $BLUE_LOG ]; then
  echo "0" > $BLUE_LOG
  chmod 666 $BLUE_LOG
fi
BLUE_STORED=`cat $BLUE_LOG 2>/dev/null`

# Log file to store the last CO2 status
CO2_LOG="/home/pi/log/last_co2_status"
if [ ! -f $CO2_LOG ]; then
  echo "0" > $CO2_LOG
  chmod 666 $CO2_LOG
fi
STORED_CO2_STATUS=`cat $CO2_LOG 2>/dev/null`

# Log file to store the last LED fan status
FAN_LOG="/home/pi/log/last_leds_cooling_status"
if [ ! -f $FAN_LOG ]; then
  echo "0" > $FAN_LOG
  chmod 666 $FAN_LOG
fi
STORED_FAN_STATUS=`cat $FAN_LOG 2>/dev/null`

# Log file to store the last AUX_A PWM level
AUX_A_LOG="/home/pi/log/last_aux_A_level"
if [ ! -f $AUX_A_LOG ]; then
  echo "0" > $AUX_A_LOG
  chmod 666 $AUX_A_LOG
fi
AUX_A_STORED=`cat $AUX_A_LOG 2>/dev/null`

# Log file to store the last AUX_B on/off status
AUX_B_LOG="/home/pi/log/last_aux_B_status"
if [ ! -f $AUX_B_LOG ]; then
  echo "0" > $AUX_B_LOG
  chmod 666 $AUX_B_LOG
fi
STORED_AUX_B_STATUS=`cat $AUX_B_LOG 2>/dev/null`

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
        echo $1 > $CO2_LOG
        echo "[$(date '+%x %X')] [$SC] Switching CO2 to status $1"
      fi
    else
      echo $1 > $CO2_LOG
      echo "[$(date '+%x %X')] [$SC] Switching CO2 to status $1"
    fi

    sleep 1
  fi
}

function writeAuxBGpioPin {
  if [ "$1" != "$STORED_AUX_B_STATUS" ]; then
    if [ "$DEBUG" = true ]; then echo "[$(date '+%x %X')] [$SC]* Stored AUX_B status: $STORED_AUX_B_STATUS"; fi

    # pot-light pin
    gpio -g write $potpin $1
    if [ "$?" -ne 0 ]; then
      echo "[$(date '+%x %X')] [$SC] Failed. Trying another time $1"
      gpio export $potpin out

      gpio -g write $potpin $1

      if [ "$?" -ne 0 ]; then
        echo $1 > $AUX_B_LOG
        echo "[$(date '+%x %X')] [$SC] Switching AUX_B to status $1"
      fi
    else
      echo $1 > $AUX_B_LOG
      echo "[$(date '+%x %X')] [$SC] Switching AUX_B to status $1"
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
        echo $1 > $FAN_LOG
        echo "[$(date '+%x %X')] [$SC] Switching LED fan to status $1"
      fi
    else
      echo $1 > $FAN_LOG
      echo "[$(date '+%x %X')] [$SC] Switching LED fan to status $1"
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
               x=$M; 
               print (x-$x1)*($y2-$y1)/($x2-$x1)+$y1" | bc | sed 's/^\./0./'`
  echo $BC
}

# Define the function to send the servoblaster command
function callServoblaster {
  STORED_LEVEL=$(eval "echo \$$3_STORED")
  CHANNEL_LOG=$(eval "echo \$$3_LOG")

  if [ "$1" != "$STORED_LEVEL" ]; then
  	if [ "$DEBUG" = true ]; then echo "[$(date '+%x %X')] [$SC]* channel log: $CHANNEL_LOG"; fi
    if [ "$DEBUG" = true ]; then echo "[$(date '+%x %X')] [$SC]* Stored $3 channell: $STORED_LEVEL"; fi
    echo "[$(date '+%x %X')] [$SC] Setting $3 ch. to $1%"

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

#

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

    auxA_y1=${AUX_A[$i]}
    auxA_y2=${AUX_A[$(( $i+1 ))]}

    auxA_value=`interpolate $x1 $auxA_y1 $x2 $auxA_y2 $M`

    callServoblaster $cold_value 2 COLD
    callServoblaster $warm_value 3 WARM
    callServoblaster $white_value 4 WHITE
    callServoblaster $blue_value 0 BLUE
    callServoblaster $auxA_value 5 AUX_A

    #echo "[$(date '+%x %X')] [$SC] COLD:$cold_value / WARM:$warm_value / WHITE:$white_value / BLUE:$blue_value"

    co2=${CO2_STATUS[$i]}
    writeCo2gpioPin $co2

    coolingFan=${FAN_STATUS[$i]}
    writeFanGpioPin $coolingFan

    auxB=${AUX_B_STATUS[$i]}
    writeAuxBGpioPin $auxB

    exit 0

  fi

done
