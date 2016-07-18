#!/bin/bash

SC=`basename $0`

auxpumppin=18

function writeAuxPumpPin {
  # LED fan gpio pin
  gpio -g write $auxpumppin $1
  if [ "$?" -ne 0 ]; then
    echo "[$(date '+%x %X')] [$SC] Failed. Trying another time $1"
    gpio export $auxpumppin out
    gpio -g write $auxpumppin $1
    if [ "$?" -ne 0 ]; then
      echo "[$(date '+%x %X')] [$SC] Switching AUX pump to status $1"
    fi
  else
    echo "[$(date '+%x %X')] [$SC] Switching AUX pump to status $1"
  fi
}

writeAuxPumpPin $1

# version with crontab job every X minutes:
# -----------------------------------------
#writeAuxPumpPin 1
#sleep 60
#writeAuxPumpPin 0
# -----------------------------------------

exit 0
