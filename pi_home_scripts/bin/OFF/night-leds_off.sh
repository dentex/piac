#!/bin/bash

# This script name
SC=`basename $0`

echo "[$(date '+%x %X')] [$SC] Switching OFF night LEDs"
sudo echo 0=0 > /dev/servoblaster
