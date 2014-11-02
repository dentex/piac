#!/bin/bash
CPU_TEMP=$(cat /sys/class/thermal/thermal_zone0/temp)
CPU_TEMP_I=$(($CPU_TEMP/1000))
CPU_TEMP_D=$(($CPU_TEMP/100))
CPU_TEMP_M=$(($CPU_TEMP_D % $CPU_TEMP_I))

echo " CPU temp=$CPU_TEMP_I.$CPU_TEMP_M'C"
echo " GPU $(/opt/vc/bin/vcgencmd measure_temp)"
