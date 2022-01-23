#!/bin/bash
sudo apt-get update -qq && DEBIAN_FRONTEND=noninteractive sudo apt-get install -yfq --no-install-recommends \
  tmux python3 python3-pip curl htop 
  
# To avoid sudo everywhere on python nvr script
# Change owenership of /etc/hosts so default user python can write over it 
sudo chown andre:andre /etc/hosts

pip install -r ~/motion_server_nvr/requeriments.txt

#mount share folder archer c7 usb external hd for uid,gid andre
if [ ! -d /mnt/motion_data  ]; then
    sudo mkdir /mnt/motion_data 
    sudo chown andre:andre /mnt/motion_data 
fi 
