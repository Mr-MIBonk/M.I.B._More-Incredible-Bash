#!/bin/sh

# esd rsdb.sh v0.1.0 (2022-01-02 by MIB-Wiki)

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

if [ ! -f /net/mmx/mnt/boardbook/RSDB/VW_STL_DB.sqlite ];then
		echo "No VW_STL_DB.sqlite found on unit"
		echo "Check if FW is compatible with RSDB"
	else
		if [ -d /net/mmx/mnt/boardbook/RSDB/ ];then
			rm -rf /net/mmx/mnt/boardbook/RSDB/*.*
			echo "RSDB folder on unit cleaned"
		fi
fi
sleep 3

if [ -f /net/mmx/fs/sda0/mod/rsdb/VW_STL_DB.sqlite ];then
	echo "Copy RSDB to unit"
	mount -uw /net/mmx/mnt/boardbook/ 2>/dev/null
	on -f mmx cp -rc /net/mmx/fs/sda0/mod/RSDB/VW_STL_DB.sqlite /net/mmx/mnt/boardbook/RSDB/ 2>/dev/null
	echo "All done, reboot unit to apply changes"
	else
		echo "VW_STL_DB.sqlite not found on SD /mod/rsdb/"
fi

echo "You can go back now..."

trap 2

exit 0

