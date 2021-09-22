# to be placed at magisk-ssh module root home folder
alias ps='ps -A'
export ps

#LD_LIBRARY_PATH=/d
#export LD_LIBRARY_PATH
# path to linuxdeploy-cli 
PATH=$PATH:/data/ssh/root/linuxdeploy-cli
export PATH

# stay awake forever
echo wake_lock_forever >> /sys/power/wake_lock
