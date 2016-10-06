#!/bin/bash

# to be called with sudo...

if [ "$1" == "enable" ]; then
  sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
  sed -i 's/PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config
  sudo service ssh restart
elif [ "$1" == "disable" ]; then
  sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
  sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
  sudo service ssh restart
else
  echo "******************************"
  echo -e "No proper parameter specified.\nUse:\n enable\nOR\n disable"
  echo "******************************"
fi
