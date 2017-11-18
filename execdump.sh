#!/bin/bash

#check nic state
ary=($(iwconfig wlan0 | grep Mode))
MODE=3
if [ ${ary[$MODE]} != "Mode:Monitor" ] 
then
    echo turning wlan0 monitor mode...
    nexutil -m2
fi

iface=${1:-wlan0}
scrpref="dump"
filepref="test"
scrname=$scrpref$(date "+%s")

trap 'nexutil -m0; sudo screen -X -S ${scrname} quit;' EXIT
sudo screen -d -m -S $scrname airodump-ng -w $filepref -o csv --write-interval 5 $iface
sleep 10
filename=$(ls -t $filepref* | head -1)
echo $filename

/usr/bin/python3.4 sendtodb.py $filename ${2:-RA-L-2.4n} 5 ${3:-192.168.11.20} ${4:-/test}
