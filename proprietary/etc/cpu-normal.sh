#!/bin/sh -x
#This is normal mode!
echo 1512000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo 100 > /sys/class/leds/lcd-backlight/brightness_fading
setprop sys.asus.power.mpdecision perf

# check if garmin exists
tokens=0
for x in `ps .apps.gmobilext`
do
    tokens=$((tokens+1))
done
 
if [ $tokens -le 8 ]; then
    setprop persist.sys.powersaving.mpdmode 1
    start mpdecision
fi
