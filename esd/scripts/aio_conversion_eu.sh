#!/bin/sh

# esd aio_conversion_eu.sh v0.1.3 (2023-06-23 by @MIB-Wiki)

trap '' 2

export PATH=.:/proc/boot:/bin:/usr/bin:/usr/sbin:/sbin:/mnt/app/media/gracenote/bin:/mnt/app/armle/bin:/mnt/app/armle/sbin:/mnt/app/armle/usr/bin:/mnt/app/armle/usr/sbin
export LD_LIBRARY_PATH=/lib:/mnt/app/root/lib-target:/eso/lib:/mnt/app/usr/lib:/mnt/app/armle/lib:/mnt/app/armle/lib/dll:/mnt/app/armle/usr/lib
unset LD_PRELOAD

export GEM=1
echo -ne "M.I.B. - More Incredible Bash "
cat /net/mmx/fs/sda0/VERSION
echo ""
echo "WARNING! NEVER interrupt the process with -Back- button"
echo "or remove SD card!!!"
echo "CAUTION: Make sure the external power is connected to the car"
echo "during any flash or programming process! Power failure during"
echo "flashing/programming will brick your unit!"
echo "All you do is at your own risk!"

thisname="$(basename $0)"
thisdir="$(dirname $0)"
. /net/mmx/fs/sda0/config/BASICS

echo -ne "\nStarting EU conversion.\nMultiple scripts will be run in series. Please wait...\n\n" | $TEE -i -a $LOG

/net/mmx/fs/sda0/apps/settrain -eu -noboot && \
/net/mmx/fs/sda0/apps/setreg -eu -noboot && \
/net/mmx/fs/sda0/apps/setvariant -var -noboot

if [[ $? -eq 0 ]]; then
	COMPONENT="$($E2P r BA D | $SED -rn 's/^0x\S+\W+(.*?)$/\1/p' | $SED -rn 's:\W*(\S\S)\W*:0x\1\n:pg' | $SED -rn '/^0x/p' | $XXD -r -p | $SED 's/[^a-zA-Z0-9_-]//g' )" 2>> $LOG
	VARREG=$($E2P r E0 1 | $SED -rn 's/^0x\S+\W+(.*?)$/\1/p') 2>> $LOG #Region: 02=EU
	if [[ "$COMPONENT" = *EU* ]] && [[ "$VARREG" = *02* ]]; then
		#Get the train from EEPROM as it can be changed already
		TRAINVERSION="$($E2P r 3A0 19 | $SED -rn 's/^0x\S+\W+(.*?)$/\1/p' | $SED -rn 's:\W*(\S\S)\W*:0x\1\n:pg' | $SED -rn '/^0x/p' | $XXD -r -p | $SED 's/[^a-zA-Z0-9_-]//g' )"
		echo -ne "\nNow reboot, insert FAT32 formatted SD card \n" | $TEE -i -a $LOG
		echo -ne "with FW $TRAINVERSION and update.\n" | $TEE -i -a $LOG
		echo -ne "IMPORTANT! If available use AIO FW version from mibsolution.one\n" | $TEE -i -a $LOG
		echo -ne "Good luck!\n"
	else
		echo -ne "\nConversion failed!!! $COMPONENT or Variant2=$VARREG is not EU!\n" | $TEE -i -a $LOG
		echo -ne "Reboot the unit and try to run conversion again!\n" | $TEE -i -a $LOG
	fi
fi

trap 2
exit 0
