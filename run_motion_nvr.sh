#!/bin/bash
export NMAP_PRIVILEGED="" # due nmap priviledge needed
python3 /home/andre/motion_server_nvr/motion_nvr.py &> /dev/null # &> /dev/null mandatory to run as a service
