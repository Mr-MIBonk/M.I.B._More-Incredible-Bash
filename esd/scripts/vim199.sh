#!/bin/sh

# esd vim199.sh v0.1.0 (2021-02-22 by MIBonk)

if [ -f /net/rcc/dev/shmem/vim.mib ]; then
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
echo""
echo "NOTE: NEVER interrupt the process with -Back- button or removing SD Card!!!"
echo "CAUTION: Ensure that a external power is connected to the car on during any"
echo "flash or programming process! Power failure during flasing/programming will"
echo "brick your unit! - All you do and use at your own risk!"
echo ""

/net/mmx/fs/sda0/apps/vim -s 0 c7

echo "All done! now you can go back..."

trap 2

exit 0

