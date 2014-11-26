#!/bin/bash

mLOG=/home/pi/log/post_up_mail_body

#echo -e "Last network events:" > $mLOG
#echo -e " $(cat /home/pi/log/last_network_down)\n" >> $mLOG

echo -e "Uptime:" > $mLOG # !!! >> $mLOG
echo -e "$(uptime)\n" >> $mLOG

echo -e "RPi Temperatures:" >> $mLOG
echo -e "$(/home/pi/bin/get_cpu_temp.sh)\n" >> $mLOG

echo -e "Water Temperature:" >> $mLOG
echo -e " $(/home/pi/bin/get_water_temp.sh)" >> $mLOG

sudo chmod 666 $mLOG

