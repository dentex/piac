#!/bin/bash

source /home/pi/bin/compose_mail_body.sh .
mitt="pi.aquarium.controller@gmail.com"
dest="samuele.rini76@gmail.com"
smtp="smtp.gmail.com"
username="pi.aquarium.controller"
pass="---"
sendemail -f $mitt -t $dest -u "INFO" -s $smtp -xu $username -xp $pass -m `cat /home/pi/log/post-up_mail_body` >> /home/pi/log/piac.log 2>&1
