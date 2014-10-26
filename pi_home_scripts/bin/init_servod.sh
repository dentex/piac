#!/bin/bash

#init servod
echo "--------------------------------------------"
servod --p1pins=11,15 --cycle-time=20000us --step-size=10us --min=10us --max 20000us
echo "--------------------------------------------"

# clean logs
#rm /home/pi/log/last_temp
rm /home/pi/log/last_fan_step

# lid cooling fan to 100% test
echo 1=100% > /dev/servoblaster
sleep 10
echo 1=0 > /dev/servoblaster
