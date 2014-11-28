#!/bin/bash

if [ "$1" == "cpu" ]; then
  cat /sys/class/thermal/thermal_zone0/temp | awk  '{x=$1}END{rounded = sprintf("%.1f", x/1000); print rounded}'
elif [ "$1" == "gpu" ]; then
  /opt/vc/bin/vcgencmd measure_temp | grep -oE '[0-9][0-9].[0-9]'
elif [ "$1" == "water" ]; then
  cat /sys/bus/w1/devices/w1_bus_master1/28-00000550758e/w1_slave | grep -oE '[0-9]{5}' | awk  '{x=$1}END{rounded = sprintf("%.1f", x/1000); print rounded}'
else
  echo "******************************"
  echo -e "No proper parameter specified.\nUse:\n cpu\n gpu\n-or-\n water  "
  echo "******************************"
fi
