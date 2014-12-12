#!/bin/bash

SC=`basename $0`

# Check if this script is already running
# http://stackoverflow.com/a/731634/1865860
if ! mkdir /tmp/$SC.lock 2>/dev/null; then
  echo "$SC is already running."
  exit 1
fi

C=1
limit=10
NONET=false

function sendMail {
  ping -c 1 -W 5 -w 5 google.it > /dev/null
  if [ "$?" -eq 0 ]; then
    NONET=false
    echo "[$(date '+%x %X')] [$SC] Sending post-up email... [$C]"
    source /home/pi/bin/compose_mail_body.sh .
    #cat /home/pi/log/post_up_mail_body | mail --debug-level=15 -s "INFO" samuele.rini76@gmail.com
    cat /home/pi/log/post_up_mail_body | mail -s "INFO" samuele.rini76@gmail.com > /dev/null
  else
    echo "[$(date '+%x %X')] [$SC] No network connection. [$C]"
    NONET=true
  fi
}

function close {
  rmdir /tmp/$SC.lock
  exit 0
}

sendMail

while [ "$?" -ne 0 ] || [ "$NONET" = true ]; do 
  echo "[$(date '+%x %X')] [$SC] Failed. Retrying in 30 sec"
  sleep 29
  let C++
  if [ "$C" -ne "$limit" ]; then
    sendMail
  else
    close
  fi
done

echo "[$(date '+%x %X')] [$SC] Email sent."

close
