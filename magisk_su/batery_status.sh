#!/system/xbin/sh
# dumpsys only work when all services are running if I use stop it wont work anymore
# dumpsys battery
print_battery_status()
{
    ctype=`cat /sys/class/power_supply/battery/charge_type`
    capacity=`cat /sys/class/power_supply/battery/capacity` 
    charging=`cat /sys/class/power_supply/battery/charging_enabled`
    health=`cat /sys/class/power_supply/battery/health`
    status=`cat /sys/class/power_supply/battery/status`
    printf "# %s # %s # %s # %s # %s #\r" "Capacity: ${capacity}" "Charging: ${charging}" "Type: ${ctype}" "Health: ${health}" "Status: ${status}"
}

# watch -n print_battery_status
while [ true ]
do
    print_battery_status
    sleep 1 # 1 second of wait
done


