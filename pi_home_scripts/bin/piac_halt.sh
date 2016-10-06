#!/bin/bash

# This script name
SC=`basename $0`

# ************************
# TO BE CALLED WITH 'SUDO'
# ************************

PIAC_LOG=/home/pi/log/piac.log
BIN="/home/pi/bin"
LOG="/home/pi/log"
sep="\n############################################"

echo $sep

pkill -f lcd_print.sh
sleep 0.2
$BIN/buzzer.py -r single-long

while getopts ":r" optname
  do
    case "$optname" in
      "r")
        echo -e $sep
        echo "Option $optname is specified: Rebooting PiAC"
        echo -e $sep

		# flag LCD not to be initialized upon reboot
        touch $LOG/do_not_init_LCD

        $BIN/lcd_print.py -d -x "      PiAC" -y "     Reboot     "
        sleep 1
        $BIN/lcd_turn_backlight_off.py
        /sbin/reboot &

        exit 0
        ;;
      "?")
        echo "Unknown option $OPTARG"
        exit 1
        ;;
      ":")
        echo "No argument value for option $OPTARG"
        exit 2
        ;;
      *)
        # Should not occur
        echo "Unknown error while processing options"
        exit 3
        ;;
    esac
  done

echo -e $sep
echo "No Option specified: Halting PiAC"
echo -e $sep

$BIN/lcd_print.py -d -x "      PiAC" -y "      Halt      "
sleep 1
$BIN/lcd_turn_backlight_off.py
/sbin/halt
