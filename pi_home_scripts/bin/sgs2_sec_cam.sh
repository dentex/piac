#!/bin/bash

function usage {
    echo -e " *** no proper parameter specified ***\n"
    echo -e " start          to START the camera"
    echo -e " stop           to STOP the camera"
    echo -e " battery        to get the BATTERY charge level\n"
}

function cam {
    if [ "$1" == "start" ]; then
        echo "STARTING security camera"
        ssh root@sgs2 -p 22220 'am start -n com.pas.webcam/.Rolling'
    elif [ "$1" == "stop" ]; then
        echo "STOPPING security camera"
        ssh root@sgs2 -p 22220 'am force-stop com.pas.webcam'
    elif [ "$1" == "battery" ]; then
        batt=`ssh root@sgs2 -p 22220 'cat /sys/class/power_supply/battery/capacity'`
        echo "SGS2 battery level: $batt%"
    else
        usage
    fi
}

cam $1
