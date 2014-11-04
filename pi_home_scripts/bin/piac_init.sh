#!/bin/bash

# Init main log
LOG="/home/pi/log/piac.log"
#echo "" > $LOG
chmod 666 $LOG

sep="--------------------------------------------"

echo "******************************************************"
echo "****** Starting Pi Aquarium Controller log file ******"
echo "******************************************************"
echo "        <<< $(date) >>>"
echo "******************************************************"
echo ""

# add some delay
sleep 40

# Clean other logs
echo -e "Cleaning logs\n>>>"
#rm -v /home/pi/log/last_temp
rm -v /home/pi/log/last_fan_step
rm -v /home/pi/log/last_t8-status
rm -v /home/pi/log/last_night-led_level
echo $sep

# Init relays' GPIO pins
echo -e "Initializing relays' GPIO pins\n>>>"
for pin in 18 23 24 25; do
  echo "Exporting pin $pin as output"
  gpio export $pin out
done
echo $sep

# Init servod
echo -e "Initializing servod\n>>>"
sudo servod --p1pins=11,15 --cycle-time=20000us --step-size=10us --min=10us --max 20000us
echo $sep

# Lid cooling fan to 100% for test
echo -e "Testing lid cooling fan to 100% for 10 sec\n>>>"
echo 1=100% > /dev/servoblaster
sleep 10
echo 1=0 > /dev/servoblaster
echo "Done."
echo $sep
