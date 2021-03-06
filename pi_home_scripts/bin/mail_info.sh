#!/bin/bash

SC=`basename $0`
LOCK_DIR=/tmp/$SC.lock

# Check if this script is already running
# http://stackoverflow.com/a/731634/1865860
if ! mkdir $LOCK_DIR 2>/dev/null; then
  echo "$SC is already running."
  exit 1
fi

trap "rmdir $LOCK_DIR; exit" INT TERM

C=0
limit=5
NONET=false
NO=false

function sendMail {
  ping -q -c 1 -W 5 -w 5 8.8.8.8 > /dev/null
  if [ "$?" -eq 0 ]; then
    NONET=false

    if [ "$1" == "no" ]; then
      echo "[$(date '+%x %X')] [$SC] Sending Normal-Ops email... [$C]"
      source /home/pi/bin/mail_body_compose.sh no .
      cat /home/pi/log/post_up_mail_body | mail -s "PiAC Normal Ops" samuele.rini76@gmail.com > /dev/null
    else
      echo "[$(date '+%x %X')] [$SC] Sending post-up email... [$C]"
      source /home/pi/bin/mail_body_compose.sh .
      cat /home/pi/log/post_up_mail_body | mail -s "PiAC Online" samuele.rini76@gmail.com > /dev/null
    fi

    #cat /home/pi/log/post_up_mail_body | mail --debug-level=15 -s "INFO" samuele.rini76@gmail.com
  else
    echo "[$(date '+%x %X')] [$SC] No network connection. [$C]"
    NONET=true
  fi
}

function close {
  rmdir $LOCK_DIR
  exit 0
}

if [ "$1" == "no" ]; then
  sendMail no
else
  sendMail
fi

while [ "$?" -ne 0 ] || [ "$NONET" = true ]; do 
  echo "[$(date '+%x %X')] [$SC] Failed. Retrying in 5 minute."
  sleep 299
  let C++
  if [ "$C" -ne "$limit" ]; then
    if [ "$1" == "no" ]; then
      sendMail no
    else
      sendMail
    fi
  else
    echo "[$(date '+%x %X')] [$SC] No network connection. Closing."
    close
  fi
done

echo "[$(date '+%x %X')] [$SC] Email sent."

close
