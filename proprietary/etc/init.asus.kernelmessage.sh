#!/system/bin/sh
kernelmessage_flag=`getprop persist.asus.kernelmessage`
is_oemuartlog_exist=`busybox cat /proc/cmdline | busybox grep UARTLOG`
if busybox test "$is_oemuartlog_exist"; then
echo 7 > /proc/sys/kernel/printk
else
echo "$kernelmessage_flag" > /proc/sys/kernel/printk
fi
