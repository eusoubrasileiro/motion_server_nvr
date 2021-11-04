#!/bin/bash
export NMAP_PRIVILEGED="" # due nmap priviledge needed
source "/home/andre/miniconda3/etc/profile.d/conda.sh"
python3 ~/motion_server_nvr/motion_nvr.py &> /dev/null 