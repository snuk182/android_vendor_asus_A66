#!/system/bin/sh
asusevtlog_enable=`getprop sys.asus.evtlog`
echo "$asusevtlog_enable" > /proc/asusevtlog-switch
