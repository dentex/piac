#!/bin/bash

PIAC_LOG=/home/pi/log/piac.log
BIN="/home/pi/bin"
LOG="/home/pi/log"
sep="\n------------------------------------------------------"

#
#

#######################################################################
#### function to wait and show progress for 20sec #####################
#######################################################################
function wait20sec {
  echo -e "Waiting 20 sec before continuing initialization:\n>>>"
  echo "-20 ..."
  $BIN/lcd_print.py -x "$(date +"%a %d %Y")" -y "[-20]  $(date +"%R %Z")"
  sleep 5
  echo "-15 ..."
  $BIN/lcd_print.py -x "$(date +"%a %d %Y")" -y "[-15]  $(date +"%R %Z")"
  sleep 5
  echo "-10 ..."
  $BIN/lcd_print.py -x "$(date +"%a %d %Y")" -y "[-10]  $(date +"%R %Z")"
  sleep 5
  echo "- 5 ..."
  $BIN/lcd_print.py -x "$(date +"%a %d %Y")" -y "[- 5]  $(date +"%R %Z")"
  sleep 5
  echo "Done."
  $BIN/lcd_print.py -x "$(date +"%a %d %Y")" -y "       $(date +"%R %Z")"
  sleep 0.5
  echo -e $sep
}
#######################################################################
#### end of wait function #############################################
#######################################################################

#
#

#######################################################################
#### part 1: BEFORE checking the date #################################
#######################################################################
function part1 {
  echo ""
  echo "******************************************************"
  echo "****** Starting Pi Aquarium Controller log file ******"
  echo "******************************************************"

  if [ -f $LOG/do_not_init_LCD ]; then
    $BIN/lcd_print.py -x " Starting  PiAC " -y " ************** "
    rm $LOG/do_not_init_LCD
  else
    $BIN/lcd_print.py -i -x " Starting  PiAC " -y " ************** "
  fi
  sleep 1
}
#######################################################################
#### end of part 1 ####################################################
#######################################################################

#
#

#######################################################################
#### part 2: AFTER checking the date ##################################
#######################################################################
function part2 {
  echo "        <<< $(date) >>>"
  echo "******************************************************"
  echo ""

  echo -e "Cleaning logs\n>>>"

  rm -v /home/pi/log/post_up_mail_body 2>/dev/null
  rm -v /home/pi/log/last_* 2>/dev/null
  echo -e $sep

  wait20sec

  $BIN/lcd_print.py -x "initializing" -y "GPIO pins..."

  # Init servod (physical pin numbers)
  # pin 11 -> 0: Blue LED Strip
  # pin 15 -> 1: Lid Cooling fan
  # pin 19 -> 2: COLD LED channel
  # pin 21 -> 3: WARM LED channel
  # pin 23 -> 4: WHITE LED channel
  # pin 29 -> 5: AUX LED channel
  echo -e "Initializing servod:\n>>>"
  sudo servod --p1pins=11,15,19,21,23,29 --cycle-time=5000us --step-size=5us --min=5us --max 5000us
  if [ "$?" -ne 0 ]; then
    echo "[$(date '+%x %X')] [$SC] Error configurating servod. Exiting."
    echo "########################### !!!! ###########################"
    exit 1
  fi
  echo -e $sep

  # Lid cooling fan to 100% for test
  $BIN/lid_fan_test.sh
  echo -e $sep

  # Init relays' GPIO pins
  echo -e "Initializing relays' GPIO pins:\n>>>"
  # (GPIO pin numbers)
  for pin in 18 23 24 25; do
    echo "Exporting pin $pin as output:"
    /usr/local/bin/gpio export $pin out
  done
  echo -e $sep

  # Flag PiAC as configured
  touch /tmp/piac_is_configured

  $BIN/lcd_print.py -x " " -y "Done."
  sleep 0.5

  wait20sec

  $BIN/lcd_print.sh >> $PIAC_LOG 2>&1 &
}
#######################################################################
#### end of part 2 ####################################################
#######################################################################

#
#
#

#######################################################################
#### PiAC init script #################################################
#######################################################################

part1

i=0
while [ `date +%Y` -eq 1970 ] && [ $i -lt 30 ]; do 
  echo "   ......   waiting for the hwclock/ntpdate   ......"
  sleep 1
  let i++
done

if [ `date +%Y` -eq 1970 ]; then
  echo "   !!!!!!   HW clock/ntpdate setting failure  !!!!!!"
  $BIN/buzzer.py -r warning
  $BIN/lcd_print.py -x "HW clock/ntpdate" - y "setting failure!"
else
  $BIN/lcd_print.py -x "$(date +"%a %d %Y")" -y "       $(date +"%R %Z")"
  $BIN/buzzer.py -r single-long
  sleep 1

  part2
fi
