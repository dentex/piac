#!/bin/bash

# This script name
SC=`basename $0`

# Initial LED intensity
I=5

echo "[$(date '+%x %X')] [$SC] Increasing night LEDs intensity from 5% to 95%"

while [ "$I" -lt 96 ]; do 
	sudo echo 0="$I%" > /dev/servoblaster
	sleep 40
	let I++
done

# tot: 60 minutes
