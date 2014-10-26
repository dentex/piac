#!/bin/bash

# This script name
SC=`basename $0`

# Initial LED intensity
I=95
echo "[$(date '+%x %X')] [$SC] Decreasing night LEDs intensity from 95% to 15%"

while [ "$I" -gt 15 ]; do 
	sudo echo 0="$I%" > /dev/servoblaster
	sleep 45
	let I--
done

# tot: 60 minutes

