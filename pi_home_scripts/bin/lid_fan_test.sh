#!/bin/bash

echo -e "Testing lid cooling fan to 100% for 10 sec...\n>>>"
echo 1=100% > /dev/servoblaster
sleep 10
echo 1=0 > /dev/servoblaster
echo "Done."
