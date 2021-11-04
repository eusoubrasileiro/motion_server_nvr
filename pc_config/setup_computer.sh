#!/bin/bash
# https://askubuntu.com/questions/15832/how-do-i-get-the-cpu-temperature
# sudo apt-get install lm-sensors

sudo apt-get update -qq && DEBIAN_FRONTEND=noninteractive sudo apt-get install -yfq --no-install-recommends \
  hddtemp lm-sensors tmux python3 python3-pip \
  nmap libcap2-bin curl htop linux-crashdump 
  
# linux-crashdump identify and traceback crashs
# https://askubuntu.com/questions/1173584/how-do-you-investigate-a-system-crash-when-there-are-no-records-logs

# identify and setup sensors for being able to use
# sudo sensors-detect

# To avoid sudo everywhere on python nvr script
# Change owenership of /etc/hosts so default user python can write over it 
sudo chown andre:andre /etc/hosts

# To give access to defaul user to use nmap full powers
# https://secwiki.org/w/Running_nmap_as_an_unprivileged_user
# Add the capabilities to Nmap. Be sure to specify the full path to wherever you installed Nmap:
# so you only need to use a export NMAP_PRIVILEGED="" before use by default user
sudo setcap cap_net_raw,cap_net_admin,cap_net_bind_service+eip /usr/bin/nmap

# disable suspend and hibernation
# https://www.tecmint.com/disable-suspend-and-hibernation-in-linux/
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
# to re-anable
# sudo systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target
# To prevent the system from going into suspend state upon closing the lid, edit the /etc/systemd/logind.conf file.
# [Login] 
# HandleLidSwitch=ignore 
# HandleLidSwitchDocked=ignore

# screen turns off automatic when closing the lid

# maybe the reason for restarts 
# remove unattended upgrades
# remove firmware updates dameon
sudo apt-get remove unattended-upgrades
sudo apt-get remove fwupd

pip install requeriments.txt