#!/bin/bash

# https://linuxconfig.org/how-to-run-script-on-startup-on-ubuntu-20-04-focal-fossa-server-desktop
sudo chmod 744 ~/motion_server_nvr/run_motion_nvr.sh
sudo cp ~/motion_server_nvr/pc_config/motion_nvr.service /etc/systemd/system/
sudo chmod 664 /etc/systemd/system/motion_nvr.service
sudo systemctl daemon-reload
sudo systemctl enable motion_nvr
sudo systemctl start motion_nvr