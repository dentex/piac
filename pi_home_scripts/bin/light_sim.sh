#!/bin/bash

# This script name
SC=`basename $0`

# GPIO pin to use
pin=18

# Total repetitions each night
RE=8

# Store $RE times between 18:00z and 21:00z and order them
times=($(shuf -i 1080-1260 -n $RE | sort -g))

# Store $RE generated hours and minutes
C=0
while [ "$C" -lt "$RE" ]; do
  hours[$C]=$((${times[$C]} / 60))

  M=$((${times[$C]} % 60))
  if [ "${#M}" -eq 1 ]; then M=0$M; fi
  minutes[$C]=$M

  #echo ${hours[$C]}:${minutes[$C]}

  let C++
done

echo "[$(date '+%x %X')] [$SC] ===================="
echo "[$(date '+%x %X')] [$SC] scheduling 'at' jobs"
echo "[$(date '+%x %X')] [$SC] ===================="

for i in `echo ${!minutes[*]}`; do
  if [ $(($i % 2)) -eq 0 ]; then
    # "even" time: enable gpio pin
    s=1
  else
    # "odd" time: disable gpio pin
    s=0
  fi

  echo "[$(date '+%x %X')] [$SC] setting command '/usr/local/bin/gpio -g write $pin $s' to run at ${hours[$i]}:${minutes[$i]}"
  echo "/usr/local/bin/gpio -g write $pin $s" | at ${hours[$i]}:${minutes[$i]}
  echo "[$(date '+%x %X')] [$SC] ***"
done
