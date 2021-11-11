#!/bin/bash
# https://askubuntu.com/questions/15832/how-do-i-get-the-cpu-temperature
# sudo apt-get install lm-sensors

sudo apt-get update -qq && DEBIAN_FRONTEND=noninteractive sudo apt-get install -yfq --no-install-recommends \
  hddtemp lm-sensors tmux python3 python3-pip \
  nmap libcap2-bin curl htop cifs-utils
  

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

pip install -r requeriments.txt

# replacing systemd by dnsmasq for domain name resolution and also
# as a minimal dns server
# https://askubuntu.com/questions/898605/how-to-disable-systemd-resolved-and-resolve-dns-with-dnsmasq

### DNS-MASQ My Custom DNS SERVER
## add your server ip to your router 
# secondary dns server
sudo apt-get install dnsmasq -y
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved
sudo bash -c "echo 'listen-address=::1,127.0.0.1,192.168.0.90
# upstream
server=192.168.0.1 
# Google's nameservers
server=8.8.8.8 
server=8.8.4.4
' >> /etc/dnsmasq.conf"
# force to use dnsmasq is only dns-server
sudo rm /etc/resolv.conf
sudo bash -c "echo '# Use local dnsmasq for resolving
nameserver 127.0.0.1
options edns0 trust-ad' > /etc/resolv.conf"
sudo systemctl stop dnsmasq
sudo systemctl start dnsmasq
# all names on /etc/hosts will be served 
# by dnsmasq
# so you can use arp-scan -localnet 
# to update then by mac-adress