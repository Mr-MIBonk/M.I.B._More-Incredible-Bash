#!/bin/sh

# esd show_qr.sh v0.1.0 (2023-05-25 by MIB-Wiki)

trap '' 2

export PATH=.:/proc/boot:/bin:/usr/bin:/usr/sbin:/sbin:/mnt/app/media/gracenote/bin:/mnt/app/armle/bin:/mnt/app/armle/sbin:/mnt/app/armle/usr/bin:/mnt/app/armle/usr/sbin
export LD_LIBRARY_PATH=/lib:/mnt/app/root/lib-target:/eso/lib:/mnt/app/usr/lib:/mnt/app/armle/lib:/mnt/app/armle/lib/dll:/mnt/app/armle/usr/lib
unset LD_PRELOAD

export GEM=1

/net/mmx/fs/sda0/apps/showimage -load 15 /net/mmx/fs/sda0/mod/images/showimage/ qr_vwg13_image_mod.png &
sleep 3

echo ""
echo "All done! You can go back now..."

trap 2

exit 0

