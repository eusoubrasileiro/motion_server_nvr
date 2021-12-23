#!/bin/bash
# https://askubuntu.com/questions/15832/how-do-i-get-the-cpu-temperature
# sudo apt-get install lm-sensors

sudo apt-get update -qq && DEBIAN_FRONTEND=noninteractive sudo apt-get install -yfq --no-install-recommends \
  tmux python3 python3-pip curl htop cifs-utils
  
# To avoid sudo everywhere on python nvr script
# Change owenership of /etc/hosts so default user python can write over it 
sudo chown andre:andre /etc/hosts

# disable suspend and hibernation
# https://www.tecmint.com/disable-suspend-and-hibernation-in-linux/
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
# to re-anable
# sudo systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target
# To prevent the system from going into suspend state upon closing the lid, edit the /etc/systemd/logind.conf file.
# [Login] 
# HandleLidSwitch=ignore 
# HandleLidSwitchDocked=ignore

pip install -r ~/motion_server_nvr/requeriments.txt

# replacing systemd by dnsmasq for domain name resolution and also
# as a minimal dns server
# https://askubuntu.com/questions/898605/how-to-disable-systemd-resolved-and-resolve-dns-with-dnsmasq

#### DNS-MASQ My Custom DNS SERVER
### add your server ip to your router 
## secondary dns server
echo "You better configure dnsmasq (custom-dns-server) by hand"
echo "All code is in setup_computer.sh"
# sudo apt-get install dnsmasq -y
# sudo systemctl stop systemd-resolved
# sudo systemctl disable systemd-resolved
# sudo bash -c "echo 'listen-address=::1,127.0.0.1,192.168.0.90
# # upstream
# server=192.168.0.1 
# # Google's nameservers
# server=8.8.8.8 
# server=8.8.4.4
# ' >> /etc/dnsmasq.conf"
# # force to use dnsmasq is only dns-server
# sudo rm /etc/resolv.conf
# sudo bash -c "echo '# Use local dnsmasq for resolving
# nameserver 127.0.0.1
# options edns0 trust-ad' > /etc/resolv.conf"
# sudo systemctl stop dnsmasq
# sudo systemctl start dnsmasq
# all names on /etc/hosts will be served 
# by dnsmasq
# so you can use arp-scan -localnet 
# to update then by mac-adress

#mount share folder archer c7 usb external hd for uid,gid andre
if [ ! -d /mnt/motion_data  ]; then
    sudo mkdir /mnt/motion_data 
    sudo chown andre:andre /mnt/motion_data 
fi 
grep -q '192.168.0.1' /etc/fstab || 
printf '//192.168.0.1/sda1   /mnt/motion_data      cifs       rw,user,nofail,uid=1000,gid=1000,vers=1.0              0 1\n' >> /etc/fstab
