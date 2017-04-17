#!/bin/bash

TT="/home/pi/bin/timetable"

t8pin=18

CONFIGURED="/tmp/piac_is_configured"

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

T8_STATUS_LOG="/home/pi/log/last_t8_status"
STORED_T8_STATUS=`cat $T8_STATUS_LOG`

# Get T8 status
T8_STATUS=( $(cat $TT | grep -v -e '^\s*$\|#' | tr -s ' '  | cut -d ' ' -f8) )

function writeT8GpioPin {
  if [ "$1" != "$STORED_T8_STATUS" ]; then

    # T8 lamps gpio pin
    gpio -g write $t8pin $1
    STORED_T8_STATUS=$1
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

  if [ "$1" != 0 ]; then
    val="$1%"
  else
    val="$1"
  fi

  echo "$2"="$val" > /dev/servoblaster
}

rm $CONFIGURED

#=====================

# Find the starting timetable's minute $M for the "fast-cycle" effect
start=$(echo "`date +%k`*60+`date +%M`" | bc)

let M=start+1

echo -e "\n ============ Sunrise/Sunset LEDs Simulation ============ "
echo " *** starting: `date` ***"
echo -e " --> $start \n"

while [ "$start" -ne "$M" ]; do

  # Skipping all late night/early morning darkness and whole day light :)
  # between 18:00 and 04:00 UTC
  if [[ "$M" -gt 1080 || "$M" -lt 240 ]]; then
    echo "... skipping night ..."
    M=240
  fi

  # between 08:40 and 13:15 UTC
  if [[ "$M" -gt 540 && "$M" -lt 795 ]]; then
    echo "... skipping daylight period ..."
    M=795
  fi

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

      t8Lamps=${T8_STATUS[$i]}
      writeT8GpioPin $t8Lamps

      echo "$M ==> COLD: $cold_value / WARM: $warm_value / WHITE: $white_value / BLUE: $blue_value / T8: $t8Lamps"

    fi

    #sleep 1

  done
  
  let M++

done

#=====================

touch $CONFIGURED

echo -e " ============ Ending LEDs Simulation ============ \n"

