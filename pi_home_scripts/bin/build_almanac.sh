#!/bin/bash

SC=`basename $0`
ALMANAC="/home/pi/almanac"

# Change this according to the desired location:
# i.e., for New York
# LAT=40.712784
# LNG=-74.005943
LAT=`/etc/get_position.sh lat`
LNG=`/etc/get_position.sh lng`

# -------------------------------

function check_network {
  ping -c 1 -w 3 8.8.8.8 > /dev/null 2>&1
  if [ "$?" -ne 0 ]; then
    echo "[$(date '+%x %X')] [$SC] No network connection. Aborting."
    exit 1
  fi
}

function test_latest_cmd {
  if [ "$?" -eq 0 ]; then
    echo "[$(date '+%x %X')] [$SC] Success."
  else
    echo "[$(date '+%x %X')] [$SC] An error occurred."
  fi
}

function fetch_data {
  # dates for a week ahead
  T0=`date +%F`
  T1=`date +%F --date='1 day'`
  T2=`date +%F --date='2 day'`
  T3=`date +%F --date='3 day'`
  T4=`date +%F --date='4 day'`
  T5=`date +%F --date='5 day'`
  T6=`date +%F --date='6 day'`

  # dates for a week ahead, without the year
  D0=`date +%m-%d`
  D1=`date +%m-%d --date='1 day'`
  D2=`date +%m-%d --date='2 day'`
  D3=`date +%m-%d --date='3 day'`
  D4=`date +%m-%d --date='4 day'`
  D5=`date +%m-%d --date='5 day'`
  D6=`date +%m-%d --date='6 day'`

  # fetch twilight data for every day
  if [ ! -f "$ALMANAC/$D0" ]; then
    echo "[$(date '+%x %X')] [$SC] Fetching almanac day $D0"
    curl -s "http://api.sunrise-sunset.org/json?lat=$LAT&lng=$LNG&date=$T0" -o $ALMANAC/$D0;
    chmod 755 $ALMANAC/$D0
    test_latest_cmd
  fi
  if [ ! -f "$ALMANAC/$D1" ]; then
    echo "[$(date '+%x %X')] [$SC] Fetching almanac day $D1"
    curl -s "http://api.sunrise-sunset.org/json?lat=$LAT&lng=$LNG&date=$T1" -o $ALMANAC/$D1;
    chmod 755 $ALMANAC/$D1
    test_latest_cmd
  fi
  if [ ! -f "$ALMANAC/$D2" ]; then
    echo "[$(date '+%x %X')] [$SC] Fetching almanac day $D2"
    curl -s "http://api.sunrise-sunset.org/json?lat=$LAT&lng=$LNG&date=$T2" -o $ALMANAC/$D2;
    chmod 755 $ALMANAC/$D2
    test_latest_cmd
  fi
  if [ ! -f "$ALMANAC/$D3" ]; then
    echo "[$(date '+%x %X')] [$SC] Fetching almanac day $D3"
    curl -s "http://api.sunrise-sunset.org/json?lat=$LAT&lng=$LNG&date=$T3" -o $ALMANAC/$D3;
    chmod 755 $ALMANAC/$D3
    test_latest_cmd
  fi
  if [ ! -f "$ALMANAC/$D4" ]; then
    echo "[$(date '+%x %X')] [$SC] Fetching almanac day $D4"
    curl -s "http://api.sunrise-sunset.org/json?lat=$LAT&lng=$LNG&date=$T4" -o $ALMANAC/$D4;
    chmod 755 $ALMANAC/$D4
    test_latest_cmd
  fi
  if [ ! -f "$ALMANAC/$D5" ]; then
    echo "[$(date '+%x %X')] [$SC] Fetching almanac day $D5"
    curl -s "http://api.sunrise-sunset.org/json?lat=$LAT&lng=$LNG&date=$T5" -o $ALMANAC/$D5;
    chmod 755 $ALMANAC/$D5
    test_latest_cmd
  fi
  if [ ! -f "$ALMANAC/$D6" ]; then
    echo "[$(date '+%x %X')] [$SC] Fetching almanac day $D6"
    curl -s "http://api.sunrise-sunset.org/json?lat=$LAT&lng=$LNG&date=$T6" -o $ALMANAC/$D6;
    chmod 755 $ALMANAC/$D6
    test_latest_cmd
  fi
}

# -----------------------------

check_network
fetch_data
