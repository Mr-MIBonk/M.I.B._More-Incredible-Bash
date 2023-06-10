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

VOLUME="/net/mmx/fs/sda0"
TEE="$VOLUME/apps/sbin/tee" # /net/mmx/usr/bin
XXD="$VOLUME/apps/sbin/xxd" # not on any unit
SED="$VOLUME/apps/sbin/sed" # /net/mmx/mnt/app/armle/usr/bin
E2P="on -f rcc /net/rcc/usr/apps/modifyE2P"
MUVERSION="MU$($E2P r 3B9 4 | $SED -rn 's/^0x\S+\W+(.*?)$/\1/p' | $SED -rn 's:\W*(\S\S)\W*:0x\1\n:pg' | $SED -rn '/^0x/p' | $XXD -r -p | $SED 's/[^a-zA-Z0-9_-]//g' )"
FAZIT="$($E2P r 9E 17 | $SED -rn 's/^0x\S+\W+(.*?)$/\1/p' | $SED -rn 's:\W*(\S\S)\W*:0x\1\n:pg' | $SED -rn '/^0x/p' | $XXD -r -p )"
#Get the real train not from GLOBALS but from EEPROM as it can be changed already
TRAINVERSION="$($E2P r 3A0 19 | $SED -rn 's/^0x\S+\W+(.*?)$/\1/p' | $SED -rn 's:\W*(\S\S)\W*:0x\1\n:pg' | $SED -rn '/^0x/p' | $XXD -r -p | $SED 's/[^a-zA-Z0-9_-]//g' )"
LOG="$VOLUME/backup/logs/$MUVERSION-$FAZIT.log"
echo -ne "\nNow you can insert FAT32 formatted SD card with FW\n" | $TEE -i -a $LOG
echo -ne "$TRAINVERSION and update.\n" | $TEE -i -a $LOG
echo -ne "IMPORTANT! If available use AIO FW version!\n" | $TEE -i -a $LOG
echo -ne "Good luck!\n"

trap 2
exit 0
