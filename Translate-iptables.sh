#!/bin/sh

sudo rm /home/debian/fichero1 2> /dev/null
sudo rm /home/debian/fichero2 2> /dev/null
sudo rm /home/debian/fichero3 2> /dev/null

sudo iptables -S > /home/debian/fichero1
sudo iptables -t nat -S >> /home/debian/fichero1

while read linea 
do
    sudo iptables-translate $linea >> /home/debian/fichero2
done < fichero1

sed 's/ ip /inet/g' /home/debian/fichero2 > /home/debian/fichero3
tr A-Z a-z < /home/debian/fichero3 > /home/debian/nftables.txt 

sudo rm /home/debian/fichero1 2> /dev/null
sudo rm /home/debian/fichero2 2> /dev/null
sudo rm /home/debian/fichero3 2> /dev/null