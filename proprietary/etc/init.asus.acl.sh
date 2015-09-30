#!/system/bin/sh
acl_mode=`getprop persist.asus.acl`
echo "$acl_mode" > /proc/driver/acl
