#!/bin/ksh

# esd cpmap_status.sh v1.0.0 (2026-10-07 by MiBonk & omonob (QCDWJ))

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
echo ""

if [ -n "${CPMAP_TEST_ROOT:-}" ] && [ -d "$CPMAP_TEST_ROOT/mnt/app" ] && [ -s "$CPMAP_TEST_ROOT/ifs/lsd.jxe" ]; then
    MMX="$CPMAP_TEST_ROOT"
elif [ -d /mnt/app ] && [ -s /ifs/lsd.jxe ]; then
    MMX=""
elif [ -d /net/mmx/mnt/app ] && [ -s /net/mmx/ifs/lsd.jxe ]; then
    MMX="/net/mmx"
else
    echo "Status: MMX filesystem not found"
    exit 1
fi

ROOT="$MMX/mnt/app/carplaymaps"
JXE="$MMX/ifs/lsd.jxe"
line=`ls -ln "$JXE" 2>/dev/null`; set -- $line
echo "CarPlay Maps VC status"
echo "lsd.jxe size: $5"
if [ -s "$ROOT/VERSION" ]; then
    echo "Version: `cat "$ROOT/VERSION"`"
    echo "Profile: `cat "$ROOT/PROFILE" 2>/dev/null`"
    echo "Runtime root: /mnt/app/carplaymaps"
else
    echo "Status: not installed"
fi

trap 2

exit 0

