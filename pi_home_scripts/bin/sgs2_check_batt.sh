#!/bin/bash

# This script name
SC=`basename $0`

# Debug true => more verbose
DEBUG=false

# GPIO pin to use
pin=23

# charge trigger thresholds
chg_thr_down=30
chg_thr_up=90

# Get the number of script's failed attempts
attempt_file="/home/pi/log/sgs2_ssh_attempts"
max_attempts=6

if [ -f $attempt_file ]; then
   attempt=`cat $attempt_file`
else
   echo 0 > $attempt_file
   attempt=0
fi

# SGS2's wall charger status (0/1, on/off)
pins_status=`gpio -g read $pin`

# SGS2's current battery level
batt=`ssh root@sgs2 -p 22220 -q 'cat /sys/class/power_supply/battery/capacity'`

if [ "$?" -ne 0 ]; then
    if [ "$DEBUG" = true ]; then echo "[$(date '+%x %X')] [$SC] Exiting due to ssh error"; fi
    let attempt++
    echo $attempt > $attempt_file

    if [ $pins_status -eq 1 ] && [ $attempt -ge $max_attempts ]; then
	    echo "[$(date '+%x %X')] [$SC] Switching charger off due to $max_attempts subsequent ssh errors"
        gpio -g write $pin 0
    fi

    exit 1
else
   echo 0 > $attempt_file
   attempt=0
fi

# Main script
if [ $batt -lt $chg_thr_down ]; then

    # if wall charger is OFF
    if [ $pins_status -eq 0 ]; then
        echo "[$(date '+%x %X')] [$SC] SGS2 battery level $batt% (below $chg_thr_down%): switching the wall charger ON"
        gpio -g write $pin 1
    else
        if [ "$DEBUG" = true ]; then echo "[$(date '+%x %X')] [$SC] SGS2 battery level $batt% (below $chg_thr_down%): charger already ON"; fi
    fi

elif [ $batt -gt $chg_thr_up ]; then

    # if wall charger is ON
    if [ $pins_status -eq 1 ]; then
        echo "[$(date '+%x %X')] [$SC] SGS2 battery level $batt% (above $chg_thr_up%): switching the wall charger OFF"
        gpio -g write $pin 0
    else
        if [ "$DEBUG" = true ]; then echo "[$(date '+%x %X')] [$SC] SGS2 battery level $batt% (above $chg_thr_up%): charger already OFF"; fi
    fi

else
    if [ $pins_status -eq 0 ]; then
        if [ "$DEBUG" = true ]; then echo "[$(date '+%x %X')] [$SC] SGS2 charger OFF"; fi
    else
        if [ "$DEBUG" = true ]; then echo "[$(date '+%x %X')] [$SC] SGS2 charger ON"; fi
    fi

    if [ "$DEBUG" = true ]; then echo "[$(date '+%x %X')] [$SC] SGS2 battery level $batt%"; fi
fi
