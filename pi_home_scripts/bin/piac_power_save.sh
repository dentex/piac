#!/bin/bash

# This script name
SC=`basename $0`

PIAC_LOG=/home/pi/log/piac.log

# LED channels PWM levels
COLD_LOG="/home/pi/log/last_leds_channel_cold_level"
COLD_STORED=`cat $COLD_LOG 2>/dev/null`

WARM_LOG="/home/pi/log/last_leds_channel_warm_level"
WARM_STORED=`cat $WARM_LOG 2>/dev/null`

WHITE_LOG="/home/pi/log/last_leds_channel_white_level"
WHITE_STORED=`cat $WHITE_LOG 2>/dev/null`

BLUE_LOG="/home/pi/log/last_leds_channel_blue_level"
BLUE_STORED=`cat $BLUE_LOG 2>/dev/null`

# AUX_A PWM level (mini-terrarium)
AUX_A_LOG="/home/pi/log/last_aux_A_level"
AUX_A_STORED=`cat $AUX_A_LOG 2>/dev/null`

# AUX_B on/off status (bowls)
AUX_B_LOG="/home/pi/log/last_aux_B_status"
AUX_B_STORED=`cat $AUX_B_LOG 2>/dev/null`

COLD=${COLD_STORED%.*}
WARM=${WARM_STORED%.*}
WHITE=${WHITE_STORED%.*}
BLUE=${BLUE_STORED%.*}
AUX_A=${AUX_A_STORED%.*}

# =============================================================

pin=(2 3 4 0 5)
i=0

# Running on-battery... (AC power lost)
if [ "$1" == "on" ]; then
    echo "[$(date '+%x %X')] [$SC $1] POWER SAVING MODE: Setting all leds to intensity 1..."  >> $PIAC_LOG 2>&1

    sudo touch /tmp/power_saving_mode
    sleep 5

    for F in $COLD $WARM $WHITE $BLUE $AUX_A; do
        if [ $F -gt 0 ]; then
            while [ $F -gt 0 ]; do
                echo "${pin[$i]}"="$F"% > /dev/servoblaster
                ((F--))
                sleep 0.1
            done
        fi
        ((i++))
    done

    if [ $AUX_B_STORED -eq 1 ]; then
        gpio -g write 25 0
    fi

# Running off-battery... (AC power restored)
elif [ "$1" == "off" ]; then
    echo "[$(date '+%x %X')] [$SC $1] Restoring all leds to previous intensity..." >> $PIAC_LOG 2>&1

    for F in $COLD $WARM $WHITE $BLUE $AUX_A; do
        v=1
        while [ $v -le $F ]; do

            echo "${pin[$i]}"="$v"% > /dev/servoblaster
            ((v++))
            sleep 0.1
        done
        ((i++))
    done

    if [ $AUX_B_STORED -eq 1 ]; then
        gpio -g write 25 1
    fi

    sudo rm /tmp/power_saving_mode
    sleep 2
    piac_manager.sh

# wrong parameter
else
    echo "[$(date '+%x %X')] [$SC] Wrong parameter!" >> $PIAC_LOG 2>&1
fi

echo "[$(date '+%x %X')] [$SC] Completed." >> $PIAC_LOG 2>&1

