#!/bin/sh -x
/system/bin/mpdclnt 1 1
echo "ondemand" >  /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
