#!/bin/bash

SC=`basename $0`
ALMANAC="/home/pi/almanac"
TIMETABLE="/home/pi/bin/timetable"
TIMETABLE_WIP="/home/pi/bin/timetable.wip"
TIMETABLE_OLD="/home/pi/bin/timetable.old"
TIMETABLE_REF="/home/pi/bin/timetable.ref"

# get today's almanac
D=`date +%m-%d`
T=$ALMANAC/$D
echo "[$(date '+%x %X')] [$SC] Today's almanac data from: $T"

# exit if data status is not OK
echo "[$(date '+%x %X')] [$SC] $D =>" `jq [.] $T | grep status`
jq '.status' $T | grep OK > /dev/null 2>&1
if [ "$?" -ne 0 ]; then
  echo "[$(date '+%x %X')] [$SC] Errors in $T. Exiting."
  exit 1
fi

# ===============================================================================

# add leading "0" to single characters minuter/hours
function add_leading_zero {
  if [ `echo $1 | grep -oE '.' | wc -l` -eq 1 ]; then
    echo 0$1
  else
    echo $1
  fi
}

function zero_fix {
  h=`echo $1 | cut -d ':' -f1`
  m=`echo $1 | cut -d ':' -f2`

  echo $(add_leading_zero $h):$(add_leading_zero $m)
}

function add_minutes {
  h=`echo $1 | cut -d ':' -f1`
  m=`echo $1 | cut -d ':' -f2`

  # `let m=m+$2` doesn't work for m < 10
  m=`echo "print $m+$2" | bc`

  while [ "$m" -gt 59 ]; do
    let h++
    let m=m-60
  done

  echo $h:$m
}

function subtract_minutes {
  h=`echo $1 | cut -d ':' -f1`
  m=`echo $1 | cut -d ':' -f2`

  m=`echo "print $m-$2" | bc`

  while [ "$m" -lt 0 ]; do
    let h--
    let m=m+60
  done

  echo $h:$m
}

# ===============================================================================

# get times from today's almanac
CTWBEG=`jq '.results.civil_twilight_begin' $T | grep -Eo '([0-9]{1,2}:[0-9]{2})'`
SUNRISE=`jq '.results.sunrise' $T | grep -Eo '([0-9]{1,2}:[0-9]{2})'`
SUNSET=`jq '.results.sunset' $T | grep -Eo '([0-9]{1,2}:[0-9]{2})'`
CTWEND=`jq '.results.civil_twilight_end' $T | grep -Eo '([0-9]{1,2}:[0-9]{2})'`

# add 12 hours to PM times
SUNSET=`add_minutes $SUNSET 720`
CTWEND=`add_minutes $CTWEND 720`

# get "shifted" sunrise/sunset times
SRp060=`add_minutes $SUNRISE 60`
SRp030=`add_minutes $SUNRISE 30`
SRp210=`add_minutes $SUNRISE 210`
SSm210=`subtract_minutes $SUNSET 210`
SSm030=`subtract_minutes $SUNSET 30`
SSm060=`subtract_minutes $SUNSET 60`

CTWBEG=`zero_fix $CTWBEG`
SUNRISE=`zero_fix $SUNRISE`
SUNSET=`zero_fix $SUNSET`
CTWEND=`zero_fix $CTWEND`
SRp060=`zero_fix $SRp060`
SRp030=`zero_fix $SRp030`
SRp210=`zero_fix $SRp210`
SSm210=`zero_fix $SSm210`
SSm030=`zero_fix $SSm030`
SSm060=`zero_fix $SSm060`

# print all calculated times for the current timetable
echo "[$(date '+%x %X')] [$SC] *****************************"
echo "[$(date '+%x %X')] [$SC] ******* new timetable *******"
echo "[$(date '+%x %X')] [$SC] *****************************"
echo "[$(date '+%x %X')] [$SC] $CTWBEG"
echo "[$(date '+%x %X')] [$SC] $SUNRISE"
echo "[$(date '+%x %X')] [$SC] $SRp030"
echo "[$(date '+%x %X')] [$SC] $SRp060"
echo "[$(date '+%x %X')] [$SC] $SRp210"
echo "[$(date '+%x %X')] [$SC] $SSm210"
echo "[$(date '+%x %X')] [$SC] $SSm060"
echo "[$(date '+%x %X')] [$SC] $SSm030"
echo "[$(date '+%x %X')] [$SC] $SUNSET"
echo "[$(date '+%x %X')] [$SC] $CTWEND"
echo "[$(date '+%x %X')] [$SC] *****************************"

# copy the reference timetable into the working copy
cp -f $TIMETABLE_REF $TIMETABLE_WIP

# substitute placeholders in "_ref" with actual times
sed -i "s/CTWBEG/$CTWBEG/" $TIMETABLE_WIP
sed -i "s/SRp000/$SUNRISE/" $TIMETABLE_WIP
sed -i "s/SRp030/$SRp030/" $TIMETABLE_WIP
sed -i "s/SRp060/$SRp060/" $TIMETABLE_WIP
sed -i "s/SRp210/$SRp210/" $TIMETABLE_WIP

sed -i "s/SSm210/$SSm210/" $TIMETABLE_WIP
sed -i "s/SSm060/$SSm060/" $TIMETABLE_WIP
sed -i "s/SSm030/$SSm030/" $TIMETABLE_WIP
sed -i "s/SSm000/$SUNSET/" $TIMETABLE_WIP
sed -i "s/CTWEND/$CTWEND/" $TIMETABLE_WIP

# store the old timetable
mv -f $TIMETABLE $TIMETABLE_OLD

# move the working copy into the timetable to be used during the day
mv -f $TIMETABLE_WIP $TIMETABLE

