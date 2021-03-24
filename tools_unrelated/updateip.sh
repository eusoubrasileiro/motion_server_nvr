#!/bin/bash
sudo nmap -sn 192.168.0.* -oX ip_mac.txt
# use python/regex to parse
#1	GWIPC-26148778	A0:9F:10:01:30:D2	192.168.0.103
#4	GWIPC-26148826	A0:9F:10:01:30:D8	192.168.0.108
# and update /etc/hosts
#sudo nano etc/hosts
#
#127.0.0.1       localhost
#::1             ip6-localhost
#192.168.0.103   ipcam_garage # A0:9F:10:01:30:D2
#192.168.0.108   ipcam_kitchen # A0:9F:10:01:30:D8
# dns hostnames its possible to call rtsp:\\user:pass@ipcam_garage:554\onvif1
# something like that. But before fix a better router and AI?
# Do I need this bellow? No I dont think so...
# TODO: create a dns server here!
