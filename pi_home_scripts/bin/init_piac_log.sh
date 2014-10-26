#!/bin/bash

LOG=/home/pi/log/piac.log

echo "******************************************************" >  $LOG
echo "****** Starting Pi Aquarium Controller log file ******" >> $LOG
echo "******************************************************" >> $LOG
echo "*********** $(date) ************"                       >> $LOG
echo "******************************************************" >> $LOG
echo ""                                                       >> $LOG

chmod 666 $LOG
