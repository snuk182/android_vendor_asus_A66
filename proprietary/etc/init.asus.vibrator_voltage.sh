#!/system/bin/sh
vibrator_voltage_mode=`getprop persist.asus.vibrator_voltage`
echo "$vibrator_voltage_mode" > /proc/driver/vibrator_voltage

