#!/bin/bash

# Init main log
LOG="/home/pi/log/piac.log"
#echo "" > $LOG
chmod 666 $LOG

sleep 10
# Check if hwclock worked properly
if [ `date +%Y` -eq 1970 ]; then
  echo " !!!! REBOOTING due to clock setting failure !!!!"
  reboot
  exit 1
fi

sep="--------------------------------------------"

echo "******************************************************"
echo "****** Starting Pi Aquarium Controller log file ******"
echo "******************************************************"
echo "        <<< $(date) >>>"
echo "******************************************************"
echo ""

# add some delay
sleep 30

# Clean other logs
echo -e "Cleaning logs\n>>>"

rm -v /home/pi/log/ngrok.log
rm -v /home/pi/log/post_up_mail_body

rm -v /home/pi/log/last_co2_status
rm -v /home/pi/log/last_fan_step
rm -v /home/pi/log/last_led_cooling_status
rm -v /home/pi/log/last_leds_channel_blue_level
rm -v /home/pi/log/last_leds_channel_cold_level
rm -v /home/pi/log/last_leds_channel_warm_level
rm -v /home/pi/log/last_leds_channel_white_level
rm -v /home/pi/log/last_t8_status
echo $sep

# Init servod
echo -e "Initializing servod\n>>>"
sudo servod --p1pins=11,15,19,21,23 --cycle-time=5000us --step-size=5us --min=5us --max 5000us
echo $sep

# Lid cooling fan to 100% for test
echo -e "Testing lid cooling fan to 100% for 10 sec\n>>>"
echo 1=100% > /dev/servoblaster
sleep 10
echo 1=0 > /dev/servoblaster
echo "Done."
echo $sep

# Init relays' GPIO pins
echo -e "Initializing relays' GPIO pins\n>>>"
for pin in 18 23 24 25; do
  echo "Exporting pin $pin as output"
  /usr/local/bin/gpio export $pin out
done
echo $sep

# Flag PiAC as configured
touch /tmp/piac_is_configured
