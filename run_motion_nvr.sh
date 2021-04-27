#!/bin/bash
# run inside tmux to avoid being killed after ssh session is over
# from
# https://askubuntu.com/q/8653/52310
# https://stackoverflow.com/q/31902929/1207193
tmux new-session -d -s motion_session
tmux send-keys -t motion_session 'python3 ~/android_ldeploy_nvr/motion_nvr.py > python_errors.txt' C-m
# tmux detach -s motion_session # dont need since -d is already detached
# don't know but doesnt work
# tmux new-session -d -s motion 'python3 android_ldeploy_nvr/motion_nvr.py > python_errors.txt'
