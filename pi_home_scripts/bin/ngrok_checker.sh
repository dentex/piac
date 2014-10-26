#!/bin/bash

SC=`basename $0`

# Hour of the day
H=`date +%H`

# run only from 08:00 to 22:59
if [ "$H" -gt 7 ] && [ "$H" -lt 23 ]; then

  # Look for the PID of ngrok
  pidof ngrok > /dev/null

  # If it's not running (no PID returned), (re)launch ngrok
  if (( $? )); then

    echo "[$(date '+%x %X')] [$SC] (Re)Launching ngrok..."
    ngrok -config=/home/pi/.ngrok -log=stdout start ssh > /home/pi/log/ngrok.log &

    if [ "$?" -eq 0 ]; then 
      echo "[$(date '+%x %X')] [$SC] Success."
    else 
      echo "[$(date '+%x %X')] [$SC] Failed."
    fi
	
  fi

fi
exit 0
