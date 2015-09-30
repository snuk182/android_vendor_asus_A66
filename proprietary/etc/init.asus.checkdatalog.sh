#!/system/bin/sh
is_datalog_exist=`busybox ls /data | busybox grep logcat_log`
startlog_flag=`getprop persist.asus.startlog`
version_type=`getprop ro.build.type`
check_factory_version=`getprop ro.asus.factory`

if busybox test -e /data/everbootup; then
	echo 1 > /data/everbootup
	startlog_flag=`getprop persist.asus.startlog`

	if busybox test "$is_datalog_exist"; then
		chown system.system /data/logcat_log
		chmod 0775 /data/logcat_log
		if busybox test "$startlog_flag" -eq 1;then
		start logcat
		start logcat-radio
		start logcat-events
		else
		stop logcat
		stop logcat-radio
		stop logcat-events
		fi
	fi        	
else
	if  busybox test "$version_type" = "eng"; then
		setprop persist.asus.startlog 1
		setprop persist.asus.kernelmessage 7
	elif busybox test "$version_type" = "userdebug"; then
			if busybox test "$check_factory_version" = "1"; then
				setprop persist.asus.kernelmessage 7
				setprop persist.asus.enable_navbar 1
			else
				setprop persist.asus.kernelmessage 0	
			fi
		setprop persist.asus.startlog 1
		setprop persist.sys.downloadmode.enable 1
		
	fi
	
	startlog_flag=`getprop persist.asus.startlog`
	recheck_datalog=`busybox ls /data | busybox grep logcat_log`

	if busybox test "$recheck_datalog"; then
		chown system.system /data/logcat_log
		chmod 0775 /data/logcat_log
		if busybox test "$startlog_flag" -eq 1;then
		start logcat
		start logcat-radio
		start logcat-events
		else
		stop logcat
		stop logcat-radio
		stop logcat-events
		fi		
	fi
	echo 0 > /data/everbootup
fi
