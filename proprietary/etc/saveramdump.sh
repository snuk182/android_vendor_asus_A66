#!/system/bin/sh

# saveramdump

SAVE_LOG_ROOT=/sdcard/logs/save_log
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
	dd if=/dev/block/mmcblk0p25 of=$SAVE_LOG_PATH/EBICS0.BIN count=292864 skip=2048
	dd if=/dev/block/mmcblk0p25 of=$SAVE_LOG_PATH/EBICS1.BIN count=1572864 skip=294912
	dd if=/dev/block/mmcblk0p25 of=$SAVE_LOG_PATH/CPUCONTEXT.BIN count=8 skip=1867776
	echo "copy RAMDUMP.bin to $SAVE_LOG_PATH"
############################################################################################
	# sync data to disk 
	sync
else
	echo "SD doesn't mount on /sdcard"
fi			
