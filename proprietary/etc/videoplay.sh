#!/bin/sh -x
#This is video play mode!
#/system/bin/mpdclnt 1 0
echo "powersave" >  /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
