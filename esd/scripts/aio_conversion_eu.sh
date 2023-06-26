#!/bin/sh

# esd aio_conversion_eu.sh v0.1.3 (2023-06-23 by @MIB-Wiki)

trap '' 2

export PATH=.:/proc/boot:/bin:/usr/bin:/usr/sbin:/sbin:/mnt/app/media/gracenote/bin:/mnt/app/armle/bin:/mnt/app/armle/sbin:/mnt/app/armle/usr/bin:/mnt/app/armle/usr/sbin
export LD_LIBRARY_PATH=/lib:/mnt/app/root/lib-target:/eso/lib:/mnt/app/usr/lib:/mnt/app/armle/lib:/mnt/app/armle/lib/dll:/mnt/app/armle/usr/lib
unset LD_PRELOAD

export GEM=1
echo -ne "M.I.B. - More Incredible Bash "
cat /net/mmx/fs/sda0/VERSION
echo ""
echo "WARNING! NEVER interrupt the process with -Back- button or remove SD card!!!"
echo "CAUTION: Make sure the external power is connected to the car during any"
echo "flash or programming process! Power failure during flasing/programming will"
echo "brick your unit! - All you do and use at your own risk!"

. /net/mmx/fs/sda0/config/BASICS

echo -ne "\nStart 1-click EU conversion\nThis will run multiple scripts in series. Stay patient!\n\n" | $TEE -i -a $LOG

/net/mmx/fs/sda0/apps/settrain -eu -noboot && \
/net/mmx/fs/sda0/apps/setreg -eu -noboot && \
/net/mmx/fs/sda0/apps/setvariant -var -noboot

[ $? -eq 0 ] && echo -ne "\nNow you can insert FAT32 formatted SD card \n" | $TEE -i -a $LOG
[ $? -eq 0 ] && echo -ne "with FW $TRAINVERSION and update.\n" | $TEE -i -a $LOG
[ $? -eq 0 ] && echo -ne "IMPORTANT! If available use AIO FW version from mibsolution.one\n" | $TEE -i -a $LOG
[ $? -eq 0 ] && echo -ne "Good luck!\n"

trap 2
exit 0
