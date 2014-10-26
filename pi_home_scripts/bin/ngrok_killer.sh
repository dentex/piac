#!/bin/bash

SC=`basename $0`

echo "[$(date '+%x %X')] [$SC] Killing ngrok..."

pkill -x ngrok

#TODO: $? doesn't report pkill success, but pgrep success
#if [ "$?" -eq 0 ]; then 
#  echo "[$(date '+%x %X')] [$SC] Success."
#else 
#  echo "[$(date '+%x %X')] [$SC] Failed."
#fi
