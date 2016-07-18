#!/bin/bash

# This script name
SC=`basename $0`

PIAC_LOG=/home/pi/log/piac.log

echo "[$(date '+%x %X')] [$SC] NOIP dynamic dns service updated" >> $PIAC_LOG 2>&1
