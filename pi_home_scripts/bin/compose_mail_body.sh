#!/bin/bash

mLOG=/home/pi/log/post-up_mail_body

echo -e "Last network events:" > $mLOG
echo -e " $(cat /home/pi/log/last_network-down)\n" >> $mLOG

echo -e "Uptime:" >> $mLOG
echo -e "$(uptime)\n" >> $mLOG

echo -e "Temperatures:" >> $mLOG
echo -e "$(/home/pi/bin/get-temp.sh)" >> $mLOG

sudo chmod 666 $mLOG

