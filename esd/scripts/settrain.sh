#!/bin/sh

# esd settrain.sh v0.1.0 (2021-03-05 by @MIB-Wiki)

trap '' 2

if [ -f /net/rcc/dev/shmem/reboot.mib ] || [ -f /net/rcc/dev/shmem/backup.mib ] || [ -f /net/rcc/dev/shmem/flash.mib ]; then
	echo "Some process is already running in background, don't interrupt!"
	exit 0
fi

export PATH=.:/proc/boot:/bin:/usr/bin:/usr/sbin:/sbin:/mnt/app/media/gracenote/bin:/mnt/app/armle/bin:/mnt/app/armle/sbin:/mnt/app/armle/usr/bin:/mnt/app/armle/usr/sbin
export LD_LIBRARY_PATH=/lib:/mnt/app/root/lib-target:/eso/lib:/mnt/app/usr/lib:/mnt/app/armle/lib:/mnt/app/armle/lib/dll:/mnt/app/armle/usr/lib
unset LD_PRELOAD

export GEM=1
echo -ne "M.I.B. - More Incredible Bash "
cat /net/mmx/fs/sda0/VERSION
echo ""
echo "WARNING! NEVER interrupt the process with -Back- button and don't remove SD Card!!!"
echo "CAUTION! Ensure that a external power is connected to the car during any"
echo "flash or programming process! Power failure during flasing/programming will"
echo "brick your unit! - All you do and use is at your own risk!"
echo ""

# Set Train to EU
/net/mmx/fs/sda0/apps/settrain -eu

trap 2

exit 0
