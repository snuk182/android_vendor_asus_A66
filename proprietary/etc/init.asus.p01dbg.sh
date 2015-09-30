#!/system/bin/sh
p01dbg_mode=`getprop persist.asus.p01dbg`
echo "$p01dbg_mode" > /proc/driver/P01_debug_key
