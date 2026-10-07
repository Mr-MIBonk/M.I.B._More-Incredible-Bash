#!/bin/sh
# copy into /mod/ on M.I.B. SD

export PATH=.:/proc/boot:/bin:/usr/bin:/usr/sbin:/sbin:/mnt/app/media/gracenote/bin:/mnt/app/armle/bin:/mnt/app/armle/sbin:/mnt/app/armle/usr/bin:/mnt/app/armle/usr/sbin
export LD_LIBRARY_PATH=/lib:/mnt/app/root/lib-target:/eso/lib:/mnt/app/usr/lib:/mnt/app/armle/lib:/mnt/app/armle/lib/dll:/mnt/app/armle/usr/lib
unset LD_PRELOAD

echo "Installing CarPlay Maps VC"
/bin/ksh "/net/mmx/fs/sda0/mod/CarPlayMapsVC/install.sh" "/net/mmx/fs/sda0/mod/CarPlayMapsVC/payload" MU1440 790
RC=$?
if [ $RC -ne 0 ]; then
    echo "FAIL: CarPlay Maps VC installation returned $RC"
    exit $RC
fi