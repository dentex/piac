#!/bin/bash

SC=`basename $0`

# Check if this script is already running
# http://stackoverflow.com/a/731634/1865860
if ! mkdir /tmp/$SC.lock 2>/dev/null; then
  echo "$SC is already running." >&2
  exit 1
fi

LOG=/home/pi/log/piac.log

C=1
limit=10

function sendMail {
  echo "[$(date '+%x %X')] [$SC] Sending post-up email... [$C]" >> $LOG 2>&1
  source /home/pi/bin/compose_mail_body.sh .
  #cat /home/pi/log/post-up_mail_body | mail --debug-level=15 -s "INFO" samuele.rini76@gmail.com >> $LOG 2>&1
  cat /home/pi/log/post-up_mail_body | mail -s "INFO" samuele.rini76@gmail.com > /dev/null
}

function close {
  rmdir /tmp/$SC.lock
  exit 0
}

sendMail

while [ "$?" -ne 0 ]; do 
  echo "[$(date '+%x %X')] [$SC] Failed. Retrying in 30 sec" >> $LOG 2>&1
  sleep 29
  let C++
  if [ "$C" -ne "$limit" ]; then
    sendMail
  else
    close
  fi
done

echo "[$(date '+%x %X')] [$SC] Email sent." >> $LOG 2>&1

close
