#!/bin/bash

BIN="/home/pi/bin"
LOG="/home/pi/log"

for i in `ls $LOG/last*`; do 
  echo "`basename $i`:"
echo "-------------------------"
  cat $i
  echo
done
