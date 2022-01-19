#!/bin/sh

# esd udevice.sh v0.1.1 (2021-04-10 by MIBonk)

trap '' 2

if [ -f /net/rcc/dev/shmem/reboot.mib ] || [ -f /net/rcc/dev/shmem/backup.mib ] || [ -f /net/rcc/dev/shmem/flash.mib ]; then
	echo "Some process is already running in background, don't interrupt!"
	exit 0
fi

export PATH=.:/proc/boot:/bin:/usr/bin:/usr/sbin:/sbin:/mnt/app/media/gracenote/bin:/mnt/app/armle/bin:/mnt/app/armle/sbin:/mnt/app/armle/usr/bin:/mnt/app/armle/usr/sbin
export LD_LIBRARY_PATH=/lib:/mnt/app/root/lib-target:/eso/lib:/mnt/app/usr/lib:/mnt/app/armle/lib:/mnt/app/armle/lib/dll:/mnt/app/armle/usr/lib
unset LD_PRELOAD

echo -ne "M.I.B. - More Incredible Bash "
cat /net/mmx/fs/sda0/VERSION
echo "NOT FOR COMMERCIAL USE - IF YOU BOUGHT THIS YOU GOT RIPPED OFF"
echo ""
echo "NOTE: NEVER interrupt the process with -Back- button or removing SD Card!!!"
echo "CAUTION: Ensure that a external power is connected to the car on during any"
echo "flash or programming process! Power failure during flasing/programming will"
echo "brick your unit! - All you do and use at your own risk!"
echo ""

echo "Install more driver for USB devices..."
mount -uw /net/mmx/mnt/system/
rm -rf /net/mmx/mnt/system/etc/usblauncher_sda0.lua
cp -rf /net/mmx/fs/sda0/mod/usblauncher/usblauncher_sda0.lua /net/mmx/mnt/system/etc/usblauncher_sda0.lua

UDEVICE=$(cat /net/mmx/mnt/system/etc/usblauncher.lua | grep usblauncher_sda0.lua)
if [ -z "$UDEVICE" ]; then
	echo -ne "dofile '/etc/usblauncher_sda0.lua'\n\n" >> /net/mmx/mnt/system/etc/usblauncher.lua
fi

UDEVICE=$(cat /net/mmx/mnt/system/etc/usblauncher_otg.lua | grep usblauncher_sda0.lua)
if [ -z "$UDEVICE" ]; then
	echo -ne "dofile '/etc/usblauncher_sda0.lua'\n\n" >> /net/mmx/mnt/system/etc/usblauncher_otg.lua
fi

echo ""
echo "All done! now you can go back..."

trap 2

exit 0

