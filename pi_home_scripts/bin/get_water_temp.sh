#!/bin/bash

#   probe output ------------------------------------------------ get raw temp -------- print it divided by 1000 and rounded to the 2nd decimal
cat /sys/bus/w1/devices/w1_bus_master1/28-00000550758e/w1_slave | grep -oE '[0-9]{5}' | awk  '{x=$1}END{rounded = sprintf("%.2f", x/1000); print rounded}'
