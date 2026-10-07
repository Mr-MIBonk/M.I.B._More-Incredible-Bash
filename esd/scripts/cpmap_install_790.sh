#!/bin/sh

# esd cpmap_install_790.sh v1.0.0 (2026-10-07 by MiBonk & omonob (QCDWJ))

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

SCRIPTS=/net/mmx/fs/sda0/mod/carplay_maps_vc
if [ -s "$SCRIPTS/cpmap_common.sh" ]; then
    . "$SCRIPTS/cpmap_common.sh"
else
    echo "FAIL: mod/carplay_maps_vc/payload was not found on SD media"
    trap 2; exit 1
fi

echo "CarPlay Maps VC - 790 AID 10.5"
echo "Free open-source project by omonob (QCDWJ)"

find_cpmap_payload || exit 1
detect_cpmap_mu || exit 1

case "$CPMAP_MU" in
    MU1102|MU1367|MU1440|MU1447) ;;
    *) trap 2; exit 1 ;;
esac

/bin/ksh "$CPMAP_PAYLOAD/common/install-carplay-maps.sh" "$CPMAP_PAYLOAD" "$CPMAP_MU" 790

trap 2

exit $?
