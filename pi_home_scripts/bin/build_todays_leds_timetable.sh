#!/bin/bash

SC=`basename $0`
ALMANAC="/home/pi/almanac"
TIMETABLE="/home/pi/bin/leds_timetable"
TIMETABLE_OLD="/home/pi/bin/leds_timetable.old"
TIMETABLE_REF="/home/pi/bin/leds_timetable_ref"

# get today's almanac data
D=`date +%m-%d`
T=$ALMANAC/$D
echo "[$(date '+%x %X')] [$SC] Today's almanac data from: $T"

# exit if data status is not OK
jq '.status' $T | grep OK
if [ "$?" -ne 0 ]; then
  echo "[$(date '+%x %X')] [$SC] Errors in $T. Exiting."
  exit 1
fi

# copy a "blank" reference timetable
mv -f $TIMETABLE $TIMETABLE_OLD
cp -f $TIMETABLE_REF $TIMETABLE

# ===============================================================================

# add leading "0" to single characters minuter/hours
function add_leading_zero {
  if [ `echo $1 | grep -oE '.' | wc -l` -eq 1 ]; then
    echo 0$1
  else
    echo $1
  fi
}

function add_minutes {
  h=`echo $1 | cut -d ':' -f1`
  m=`echo $1 | cut -d ':' -f2`

  let m=m+$2

  while [ "$m" -gt 59 ]; do
    let h++
    let m=m-60
  done

  echo $h:$(add_leading_zero $m)
}

function subtract_minutes {
  h=`echo $1 | cut -d ':' -f1`
  m=`echo $1 | cut -d ':' -f2`

  let m=m-$2

  while [ "$m" -lt 0 ]; do
    let h--
    let m=m+60
  done

  echo $h:$(add_leading_zero $m)
}

# ===============================================================================

# get times
NAUTICAL_TW_BEG=`jq '.results.nautical_twilight_begin' $T | grep -Eo '([0-9]{1,2}:[0-9]{2})'`
CIVIL_TW_BEG=`jq '.results.civil_twilight_begin' $T | grep -Eo '([0-9]{1,2}:[0-9]{2})'`
SUNRISE=`jq '.results.sunrise' $T | grep -Eo '([0-9]{1,2}:[0-9]{2})'`
SUNSET=`jq '.results.sunset' $T | grep -Eo '([0-9]{1,2}:[0-9]{2})'`
CIVIL_TW_END=`jq '.results.civil_twilight_end' $T | grep -Eo '([0-9]{1,2}:[0-9]{2})'`
NAUTICAL_TW_END=`jq '.results.nautical_twilight_end' $T | grep -Eo '([0-9]{1,2}:[0-9]{2})'`

# add 12 hours to AM times
SUNSET=`add_minutes $SUNSET 720`
CIVIL_TW_END=`add_minutes $CIVIL_TW_END 720`
NAUTICAL_TW_END=`add_minutes $NAUTICAL_TW_END 720`

# get "shifted" sunrise/sunset times
SUNRISEp60=`add_minutes $SUNRISE 60`
SUNRISEp30=`add_minutes $SUNRISE 30`
SUNRISEp210=`add_minutes $SUNRISE 210`
SUNSETm210=`subtract_minutes $SUNSET 210`
SUNSETm30=`subtract_minutes $SUNSET 30`
SUNSETm60=`subtract_minutes $SUNSET 60`

# print all calculated times for the current timetable
echo "============================================================="
echo "[$(date '+%x %X')] [$SC] $NAUTICAL_TW_BEG"
echo "[$(date '+%x %X')] [$SC] $CIVIL_TW_BEG"
echo "[$(date '+%x %X')] [$SC] $SUNRISE"
echo "[$(date '+%x %X')] [$SC] $SUNRISEp30"
echo "[$(date '+%x %X')] [$SC] $SUNRISEp60"
echo "[$(date '+%x %X')] [$SC] $SUNRISEp210"
echo ""
echo "[$(date '+%x %X')] [$SC] $SUNSETm210"
echo "[$(date '+%x %X')] [$SC] $SUNSETm60"
echo "[$(date '+%x %X')] [$SC] $SUNSETm30"
echo "[$(date '+%x %X')] [$SC] $SUNSET"
echo "[$(date '+%x %X')] [$SC] $CIVIL_TW_END"
echo "[$(date '+%x %X')] [$SC] $NAUTICAL_TW_END"
echo "============================================================="

# substitute placeholders in "_ref" with actual times
sed -i "s/NAUTICAL_TW_BEG/$NAUTICAL_TW_BEG/" $TIMETABLE
sed -i "s/CIVIL_TW_BEG/$CIVIL_TW_BEG/" $TIMETABLE
sed -i "s/SUNRISEp0/$SUNRISE/" $TIMETABLE
sed -i "s/SUNRISEp30/$SUNRISEp30/" $TIMETABLE
sed -i "s/SUNRISEp60/$SUNRISEp60/" $TIMETABLE
sed -i "s/SUNRISEp210/$SUNRISEp210/" $TIMETABLE

sed -i "s/SUNSETm210/$SUNSETm210/" $TIMETABLE
sed -i "s/SUNSETm60/$SUNSETm60/" $TIMETABLE
sed -i "s/SUNSETm30/$SUNSETm30/" $TIMETABLE
sed -i "s/SUNSETm0/$SUNSET/" $TIMETABLE
sed -i "s/CIVIL_TW_END/$CIVIL_TW_END/" $TIMETABLE
sed -i "s/NAUTICAL_TW_END/$NAUTICAL_TW_END/" $TIMETABLE






