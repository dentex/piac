# Lid cooling fan to 100% for cooling push
echo "Testing lid cooling fan to 100% for 30 sec"
echo 1=100% > /dev/servoblaster
sleep 30
echo 1=0 > /dev/servoblaster
echo "Done"
