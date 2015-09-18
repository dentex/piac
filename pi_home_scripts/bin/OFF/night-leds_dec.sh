#!/bin/bash

# This script name
SC=`basename $0`

# Initial LED intensity
I=15

echo "[$(date '+%x %X')] [$SC] Decreasing night LEDs intensity from 15% to 1%"

while [ "$I" -gt 0 ]; do 
	sudo echo 0="$I%" > /dev/servoblaster
	sleep 120
	let I--
done
