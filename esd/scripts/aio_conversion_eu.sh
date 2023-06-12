#!/bin/sh

# esd aio_conversion_eu.sh v0.1.0 (2023-05-16 by @MIB-Wiki)

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

# EU conversion
/net/mmx/fs/sda0/apps/settrain -eu -noboot && \
/net/mmx/fs/sda0/apps/setreg -eu -noboot && \
/net/mmx/fs/sda0/apps/setvariant -var -noboot

. /net/mmx/fs/sda0/config/BASICS

if [[ "$TRAINVERSION" = *EU* ]]; then
	echo -ne "\nNow you can insert FAT32 formatted SD card with FW\n" | $TEE -i -a $LOG
	echo -ne "$TRAINVERSION and update.\n" | $TEE -i -a $LOG
	echo -ne "IMPORTANT! If available use AIO FW version!\n" | $TEE -i -a $LOG
	echo -ne "Good luck!\n"
else
	echo -ne "\nConversion failed!\n"
	if [[ ! -e $LOG ]]; then
		echo -ne "\nSD card is write protected!!!\n"
	else
		echo -ne "\nCreate issue and attach the log from backup folder at\n"
		echo -ne "https://github.com/Mr-MIBonk/M.I.B._More-Incredible-Bash/issues"
	fi
fi

trap 2
exit 0
