#!/bin/bash
sudo apt-get update -qq && DEBIAN_FRONTEND=noninteractive sudo apt-get install -yfq --no-install-recommends \
  tmux python3 python3-pip curl htop 

# no requeriments for motion_helper.py
pip install -r ~/motion_server_nvr/requeriments.txt

#to mount usb external hd for uid,gid andre
if [ ! -d /mnt/motion_data  ]; then
    sudo mkdir /mnt/motion_data 
    sudo chown andre:andre /mnt/motion_data 
fi 

# Change ownership of /etc/hosts so default user 
sudo chown andre:andre /etc/hosts
echo "# from archer c7 router address reservation / security -> mac binding
192.168.0.179   ipcam.street # 9C-A3-A9-6A-87-5B
192.168.0.12    ipcam.frontwall # A0-9F-10-00-93-C6
192.168.0.11    ipcam.kitchen # A0-9F-10-01-30-D8
192.168.0.13    ipcam.garage #A0-9F-10-01-30-D2 " >> /etc/hosts

