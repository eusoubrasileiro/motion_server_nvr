#!/bin/bash

#only var folder for while

if [ "$1" == "start" ]; then 
    systemctl stop nginx 
    # create folders needed by overlay filesystem
    mkdir -p /dev/shm/var_upper /dev/shm/var_workdir /dev/shm/var_overlay
    mkdir -p /var_
    # since /var will be 'hidden' by overlay mouting over it
    # we need it 'visible' somewhere to be usable as lowerdir 
    # mount --bind does that to /var_
    mount --bind /var /var_ 
    mount -t overlay overlay -o lowerdir=/var_,upperdir=/dev/shm/var_upper,workdir=/dev/shm/var_workdir /var 
    systemctl start nginx 
fi

if [ "$1" == "stop" ]; then 
    # might fail in case use lsof to kill process?
    # normally nginx or jounalctl or someoneelse writting logs
    # lsof +D /var > open_files.txt
    systemctl stop nginx 
    umount /var_ 
    umount /var  
    systemctl start nginx 
fi


# Overlay mounts a union filesystem (or directory tree) where upper directory is protected
# it's safe for reboot since unbind will be done and everything will got back to it's default
# - name: Overlay mount /var making it read only - rw only on RAM /dev/shm (logs lost on reboot)
#   shell: !
#     # create folders needed by overlay filesystem
#     mkdir -p /dev/shm/var_upper /dev/shm/var_workdir /dev/shm/var_overlay
#     mkdir -p /var_
#     # since /var will be 'hidden' by overlay mouting over it
#     # we need it 'visible' somewhere to be usable as lowerdir 
#     # mount --bind does that to /var_
#     mount --bind /var /var_
#     sudo mount -t overlay overlay -o lowerdir=/var_,upperdir=/dev/shm/var_upper,workdir=/dev/shm/var_workdir /var
#   become: true
#   tags:
#     - never
#     - overlay
#   # special tag never run unless explicitly specified --tags overlay

# I have played with script line bellow. To find which folders get written on.
# to get which files were last modified recursivly inside current folder
# find $1 -type f -print0 | xargs -0 stat --format '%Y :%y %n' | sort -nr | cut -d: -f2- | head    

# # Set everything read only with chattr +i (imutable) ?? will work ??
# # not sure and on reboot everything cannot be written on
# # read-only prevent filesystem  corruption when energy goes down ?
# # to revert back
# # chattr -R -i /boot /lib /opt /usr /bin /sbin /etc 
# # must change back to real file on shutdown
# - name: Turn /var tmpfs from a tarbal backup
#   shell: !
#     cd /
#     tar -pcvzf var.tar.gz var
#     rm -rf /var/* 
#     mount -t tmpfs -o size=350M tmpfs /var
#     tar -xpvzf var.tar.gz
#   become: true
#   tags:
#     - never    
#   # special tag never run unless explicitly specified --tags never