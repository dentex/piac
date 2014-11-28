#!/bin/bash

echo " CPU `cat /sys/class/thermal/thermal_zone0/temp | awk  '{x=$1}END{rounded = sprintf("%.1f", x/1000); print rounded}'`°C"
echo " GPU `/opt/vc/bin/vcgencmd measure_temp | grep -oE '[0-9][0-9].[0-9]'`°C"
