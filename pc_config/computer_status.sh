	
#my power source cable is for maximum 65W 
# my battery is maximum 45w so probably using less than this
# my TDP is 35W so maximum consuption
# my wifi around 4W maximum  
# my screen less than 20W around full use (source internet)
# so without screen 4W+35W~40W if at 50% usage cpu = 20W
upower -i /org/freedesktop/UPower/devices/battery_BAT0
# https://askubuntu.com/questions/15832/how-do-i-get-the-cpu-temperature
#sudo hddtemp /dev/sda    
sensors

