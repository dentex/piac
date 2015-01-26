#!/bin/bash

mLOG=/home/pi/log/post_up_mail_body

#echo -e "Last network events:" > $mLOG # !!! >> $mLOG
#echo -e " $(cat /home/pi/log/last_network_down)\n" >> $mLOG

echo -e "Date:" > $mLOG
echo -e " $(date)\n" >> $mLOG

echo -e "Uptime:" >> $mLOG
echo -e "$(uptime)\n" >> $mLOG

echo -e "RPi Temperatures:" >> $mLOG
echo -e "$(/home/pi/bin/get_rpi_temp.sh)\n" >> $mLOG

echo -e "Water Temperature:" >> $mLOG
echo -e " $(/home/pi/bin/get_temp.sh water)°C" >> $mLOG

sudo chmod 666 $mLOG

