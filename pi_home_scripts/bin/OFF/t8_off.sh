#!/bin/bash

SC=`basename $0`

echo "[$(date '+%x %X')] [$SC] Switching T8 lights OFF"
gpio export 18 out
gpio -g write 18 0
