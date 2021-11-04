#!/bin/bash
export NMAP_PRIVILEGED=""
# nmap --privileged -sS 192.168.0.1 from https://secwiki.org/w/Running_nmap_as_an_unprivileged_user 
#    to avoid typing passwd again/again - need to install and config libcap
#    or 
#    export NMAP_PRIVILEGED=""
export NMAP_PRIVILEGED=""
# run inside tmux to avoid being killed after ssh session is over
# from
# https://askubuntu.com/q/8653/52310
# https://stackoverflow.com/q/31902929/1207193
# dont know how to re-start though - repeating the commands don't restart 'python3 motion_nvr.py'
tmux new -d -s motion_tmux
tmux send -t motion_tmux 'python3 ~/motion_server_nvr/motion_nvr.py &> /dev/null' ENTER
#tmux send-keys -t motion_session 'python3 ~/motion_server_nvr/motion_nvr.py '
# ALT+B after D detachs
# `tmux attach` to attach back again and see what happend to Motion
