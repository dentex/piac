#!/bin/bash

mLOG=/home/pi/log/post_up_mail_body

#echo -e "Last network events:" > $mLOG # !!! >> $mLOG
#echo -e " $(cat /home/pi/log/last_network_down)\n" >> $mLOG

if [ "$1" == "no" ]; then
  echo -e "PiAC Normal Ops at:" > $mLOG
else
  echo -e "PiAC Online at:" > $mLOG
fi

echo -e " $(date)\n" >> $mLOG

echo -e "Uptime:" >> $mLOG
echo -e "$(uptime)\n" >> $mLOG

echo -e "ext. IP" >> $mLOG
IP=`curl -sA 'curl/7.26.0 (arm-unknown-linux-gnueabihf) libcurl/7.26.0 OpenSSL/1.0.1t zlib/1.2.7 libidn/1.25 libssh2/1.4.2 librtmp/2.3' http://ipv4bot.whatismyipaddress.com/`
if [ -z "$IP" ]; then
  IP=`curl -s http://checkip.amazonaws.com/`
fi
echo -e " $IP\n" >> $mLOG

echo -e "RPi Temperatures:" >> $mLOG
echo -e "$(/home/pi/bin/get_rpi_temp.sh)\n" >> $mLOG

echo -e "RPi Case Temperature:" >> $mLOG
echo -e " $(/home/pi/bin/get_temp.sh case)°C\n" >> $mLOG

echo -e "Water Temperature:" >> $mLOG
echo -e " $(/home/pi/bin/get_temp.sh water)°C" >> $mLOG

sudo chmod 666 $mLOG

