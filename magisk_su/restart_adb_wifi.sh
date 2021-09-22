#!/system/bin/sh
# restart adb over wifi
setprop service.adb.tcp.port 5555
stop adbd
start adbd
