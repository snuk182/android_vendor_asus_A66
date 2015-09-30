#!/system/bin/sh
# Always write emmc
#

sleep 30

while :;
do
   echo "write 100MB file to /mnt/sdcard"
   dd if=/dev/zero of=/mnt/sdcard/test bs=104857600 count=1
   sleep 2
done
