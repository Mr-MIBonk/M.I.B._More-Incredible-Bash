#!/bin/sh

# esd advanced backup.sh v0.1.1 (2021-04-05 by MIBonk)

if [ -f /net/rcc/dev/shmem/backup.mib ] || [ -f /net/rcc/dev/shmem/reboot.mib ] || [ -f /net/rcc/dev/shmem/flash.mib ]; then
	echo "Some process is already running in background, don't interrupt!"
	exit 0
fi

trap '' 2

export PATH=.:/proc/boot:/bin:/usr/bin:/usr/sbin:/sbin:/mnt/app/media/gracenote/bin:/mnt/app/armle/bin:/mnt/app/armle/sbin:/mnt/app/armle/usr/bin:/mnt/app/armle/usr/sbin
export LD_LIBRARY_PATH=/lib:/mnt/app/root/lib-target:/eso/lib:/mnt/app/usr/lib:/mnt/app/armle/lib:/mnt/app/armle/lib/dll:/mnt/app/armle/usr/lib
unset LD_PRELOAD

export GEM=1
echo -ne "M.I.B. - More Incredible Bash "
cat /net/mmx/fs/sda0/VERSION
echo "NOT FOR COMMERCIAL USE - IF YOU BOUGHT THIS YOU GOT RIPPED OFF"
echo ""
echo "NOTE: NEVER interrupt the process with -Back- button or removing SD Card!!!"
echo "CAUTION: Ensure that a external power is connected to the car on during any"
echo "flash or programming process! Power failure during flasing/programming will"
echo "brick your unit! - All you do and use at your own risk!"

on -f rcc /net/mmx/fs/sda0/apps/backup -a
sleep 3

echo "There is no patch for your train version available?"
echo "You want to support the project?"
echo "-> Send us a copy of the /backup/ folder from your SD card"
echo "-> Upload to https://mibsolution.one - user:guest pass:guest"
echo "  -> folder: M.I.B_backup"
echo ""
echo "All done! now you can go back..."

trap 2

exit 0
