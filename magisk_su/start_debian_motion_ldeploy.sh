# not using shebang because is causing problems
# start linux deploy container than start motion_nvr script inside it
/data/ssh/root/linuxdeploy-cli/cli.sh -p debian start -m
/data/ssh/root/linuxdeploy-cli/cli.sh shell -u android '/home/android/android_ldeploy_nvr/run_motion_nvr.sh'
# remember port 8022 ssh
# script bellow executed inside chroot linux deploy
## run_motion_nvr.sh
##!/bin/bash
## run inside tmux to avoid being killed after ssh session is over
## from
## https://askubuntu.com/q/8653/52310
## https://stackoverflow.com/q/31902929/1207193
## dont know how to re-start though - repeating the commands don't restart 'python3 motion_nvr.py'
# tmux new -d -s motion_tmux
# tmux send -t motion_tmux 'python3 ~/android_ldeploy_nvr/motion_nvr.py' ENTER
## ALT+B after D detachs
## `tmux attach` to attach back again and see what happend to Motion
