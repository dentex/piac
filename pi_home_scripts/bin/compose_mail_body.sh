#!/bin/bash

mLOG=/home/pi/log/post_up_mail_body

#echo -e "Last network events:" > $mLOG
#echo -e " $(cat /home/pi/log/last_network_down)\n" >> $mLOG

echo -e "Uptime:" > $mLOG # !!! >> $mLOG
echo -e "$(uptime)\n" >> $mLOG

echo -e "Temperatures:" >> $mLOG
echo -e "$(/home/pi/bin/get_temp.sh)" >> $mLOG

sudo chmod 666 $mLOG

