#!/system/bin/sh

# savelog

SAVE_LOG_ROOT=$(getprop ro.epad.mount_point.microsd)/save_log
BUSYBOX=busybox

# check mount file
is_sd_exist=`busybox cat /proc/mounts | busybox grep /sdcard`
if busybox test "$is_sd_exist"; then
	# sync log to flash 
	sync
	echo "sdcard is mounted"

	# check free space is larger than 50M
	P_SIZE=`busybox df /sdcard`
	
	i=1
	for size in $P_SIZE; do
		if busybox test $i -eq 11 ; then
			AVAIABLE=`busybox echo $size | busybox sed "s/K//g"`
			break
		fi
		i=$(($i+1));
	
	done
	
	if busybox test $AVAIABLE -le 1024000 ; then
		echo "Create log directory: $SAVE_LOG_ROOT/Can't Save: Free Space $AVAIABLE Kbytes"
		exit
	fi
############################################################################################	
	# create savelog folder (UTC)
	SAVE_LOG_PATH="$SAVE_LOG_ROOT/`date +%Y_%m_%d_%H_%M_%S`"
	$BUSYBOX mkdir -p $SAVE_LOG_PATH
	echo "$BUSYBOX mkdir -p $SAVE_LOG_PATH"
############################################################################################
	# save cmdline
	busybox cat /proc/cmdline > $SAVE_LOG_PATH/cmdline.txt
	echo "cat /proc/cmdline > $SAVE_LOG_PATH/cmdline.txt"	
############################################################################################
	# save mount table
	busybox cat /proc/mounts > $SAVE_LOG_PATH/mounts.txt
	echo "cat /proc/mounts > $SAVE_LOG_PATH/mounts.txt"
############################################################################################
	# save property
	getprop > $SAVE_LOG_PATH/getprop.txt
	echo "getprop > $SAVE_LOG_PATH/getprop.txt"
############################################################################################
	# save network info
	busybox route -n > $SAVE_LOG_PATH/route.txt
	echo "busybox route -n > $SAVE_LOG_PATH/route.txt"
	busybox ifconfig -a > $SAVE_LOG_PATH/ifconfig.txt
	echo "busybox ifconfig -a > $SAVE_LOG_PATH/ifconfig.txt"
############################################################################################
	# save software version
	AP_VER=`getprop ro.build.display.id`
	CP_VER=`getprop gsm.version.baseband`
	BUILD_DATE=`getprop ro.build.date`
	echo "AP_VER: $AP_VER" > $SAVE_LOG_PATH/version.txt
	echo "CP_VER: $CP_VER" >> $SAVE_LOG_PATH/version.txt
	echo "BUILD_DATE: $BUILD_DATE" >> $SAVE_LOG_PATH/version.txt
############################################################################################
	# save load kernel modules
	busybox lsmod > $SAVE_LOG_PATH/lsmod.txt
	echo "lsmod > $SAVE_LOG_PATH/lsmod.txt"
############################################################################################
	# save process now
	busybox ps -To user,pid,ppid,vsz,rss,args > $SAVE_LOG_PATH/ps.txt
	echo "busybox ps > $SAVE_LOG_PATH/ps.txt"
############################################################################################
	# save kernel message
	dmesg > $SAVE_LOG_PATH/dmesg.txt
	echo "dmesg > $SAVE_LOG_PATH/dmesg.txt"
############################################################################################
	# copy data/log to sdcard
	busybox ls -R -l /data/log/ > $SAVE_LOG_PATH/ls_data_log.txt
	$BUSYBOX cp -r /data/log/ $SAVE_LOG_PATH
	echo "$BUSYBOX cp -r /data/log/ $SAVE_LOG_PATH"
############################################################################################
	# copy data/logcat_log to data/media
	busybox ls -R -l /data/logcat_log/ > $SAVE_LOG_PATH/ls_data_logcat_log.txt
	$BUSYBOX cp -r /data/logcat_log/ $SAVE_LOG_PATH
	echo "$BUSYBOX cp -r /data/logcat_log $SAVE_LOG_PATH"
############################################################################################
	# copy /sdcard/asus_log to sdcard
	busybox ls -R -l /sdcard/asus_log/ > $SAVE_LOG_PATH/ls_sdcard_asus_log.txt
	busybox cp -r /sdcard/asus_log/ $SAVE_LOG_PATH
	echo "busybox cp -r /sdcard/asus_log/ $SAVE_LOG_PATH"
############################################################################################
	# cp /data/anr to sdcard
	busybox ls -R -l /data/anr > $SAVE_LOG_PATH/ls_data_anr.txt
	busybox cp /data/anr $SAVE_LOG_PATH
	echo "cp /data/anr $SAVE_LOG_PATH"
############################################################################################
	# copy asusdbg(reset debug message) to /sdcard
	$BUSYBOX mkdir -p $SAVE_LOG_PATH/resetdbg
	dd if=/dev/block/mmcblk0p25 of=$SAVE_LOG_PATH/resetdbg/kernelmessage.txt count=512
	dd if=/dev/block/mmcblk0p25 of=$SAVE_LOG_PATH/resetdbg/logcat_main count=512 skip=512
	dd if=/dev/block/mmcblk0p25 of=$SAVE_LOG_PATH/resetdbg/logcat_system count=512 skip=1024
	dd if=/dev/block/mmcblk0p25 of=$SAVE_LOG_PATH/resetdbg/logcat_radio count=512 skip=1536
	echo "copy asusdbg(reset debug message) to $SAVE_LOG_PATH/resetdbg"
############################################################################################
is_ramdump_exist=`busybox cat /proc/cmdline | busybox grep RAMDUMP`
if busybox test "$is_ramdump_exist"; then
	dd if=/dev/block/mmcblk0p25 of=$SAVE_LOG_PATH/EBICS0.BIN count=292864 skip=2048
	dd if=/dev/block/mmcblk0p25 of=$SAVE_LOG_PATH/EBICS1.BIN count=1572864 skip=294912
	dd if=/dev/block/mmcblk0p25 of=$SAVE_LOG_PATH/CPUCONTEXT.BIN count=8 skip=1867776
	echo "copy RAMDUMP.bin to $SAVE_LOG_PATH"
fi	
############################################################################################
	# save system information
	dumpsys SurfaceFlinger > $SAVE_LOG_PATH/surfaceflinger.dump.txt
	echo "dumpsys SurfaceFlinger > $SAVE_LOG_PATH/surfaceflinger.dump.txt"
	dumpsys window > $SAVE_LOG_PATH/window.dump.txt
	echo "dumpsys window > $SAVE_LOG_PATH/window.dump.txt"
	dumpsys activity > $SAVE_LOG_PATH/activity.dump.txt
	echo "dumpsys activity > $SAVE_LOG_PATH/activity.dump.txt"
	dumpsys power > $SAVE_LOG_PATH/power.dump.txt
	echo "dumpsys power > $SAVE_LOG_PATH/power.dump.txt"
	dumpsys input_method > $SAVE_LOG_PATH/input_method.dump.txt
	echo "dumpsys input_method > $SAVE_LOG_PATH/input_method.dump.txt"
	date > $SAVE_LOG_PATH/date.txt
	echo "date > $SAVE_LOG_PATH/date.txt"
############################################################################################	
	# save debug report
	dumpsys > $SAVE_LOG_PATH/bugreport.txt
	echo "dumpsys > $SAVE_LOG_PATH/bugreport.txt"
############################################################################################
	busybox mv /data/media/diag_logs/QXDM_logs $SAVE_LOG_PATH 
	echo "busybox mv /data/media/diag_logs/QXDM_logs $SAVE_LOG_PATH"
	SDCARDPATH=$(getprop ro.epad.mount_point.microsd)
	busybox mv $SDCARDPATH/diag_logs/QXDM_logs $SAVE_LOG_PATH 
	echo "busybox mv /sdcard/diag_logs/QXDM_logs $SAVE_LOG_PATH"
############################################################################################
	date > $SAVE_LOG_PATH/microp_dump.txt
	 busybox cat /d/gpio >> $SAVE_LOG_PATH/microp_dump.txt                   
        echo "cat /d/gpio > $SAVE_LOG_PATH/microp_dump.txt"  
    busybox cat /d/microp >> $SAVE_LOG_PATH/microp_dump.txt
    echo "cat /d/microp > $SAVE_LOG_PATH/microp_dump.txt"
############################################################################################
	# sync data to disk 
	sync
	chmod -R 777 "$SAVE_LOG_PATH"
am broadcast -a android.intent.action.MEDIA_MOUNTED --ez read-only false -d file:///Removable/MicroSD
	
else
	echo "SD doesn't mount on /sdcard"
fi
