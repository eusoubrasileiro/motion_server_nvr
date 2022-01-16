#!/bin/bash

# https://linuxconfig.org/how-to-run-script-on-startup-on-ubuntu-20-04-focal-fossa-server-desktop
# 2 systemd services 
# 1 (motiond) only for calling-restarting motion
# 2 (helper) for updating /etc/hosts, recover space etc.
sudo chmod 744 ~/motion_server_nvr/motion_helper.py
sudo cp ~/motion_server_nvr/scripts/motion.service /etc/systemd/system/
sudo cp ~/motion_server_nvr/scripts/motion_helper.service /etc/systemd/system/
sudo chmod 664 /etc/systemd/system/motion.service
sudo chmod 664 /etc/systemd/system/motion_helper.service
sudo systemctl daemon-reload
sudo systemctl enable motion
sudo systemctl enable motion_helper
sudo systemctl start motion_helper
sudo systemctl start motion