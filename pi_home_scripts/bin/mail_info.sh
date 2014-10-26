#!/bin/bash

SC=`basename $0`
LOG=/home/pi/log/piac.log

C=1

function sendMail {
  echo "[$(date '+%x %X')] [$SC] Sending post-up email... [$C]" >> $LOG 2>&1
  source /home/pi/bin/compose_mail_body.sh .
  #cat /home/pi/log/post-up_mail_body | mail --debug-level=15 -s "INFO" samuele.rini76@gmail.com >> $LOG 2>&1
  cat /home/pi/log/post-up_mail_body | mail -s "INFO" samuele.rini76@gmail.com > /dev/null
}

sendMail

while [ "$?" -ne 0 ]; do 
  echo "[$(date '+%x %X')] [$SC] Failed. Retrying in 30 sec" >> $LOG 2>&1
  sleep 29
  let C++
  sendMail
done

echo "[$(date '+%x %X')] [$SC] Email sent." >> $LOG 2>&1
exit 0
