#!/bin/bash
python3 /home/andre/motion_server_nvr/motion_nvr.py -d /mnt/motion_data -s /home/andre &> /dev/null # &> /dev/null mandatory to run as a service
