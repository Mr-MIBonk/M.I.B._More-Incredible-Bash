#!/bin/ksh

# change this file to run any command, script or binary from SD
# no need to touch metainfo2.txt as this is outside of its reach
# final script  run time is set to 30s in metainfo2.txt
# if you need more time extend FinalScriptMaxTime = XX
# add echo to output debugging information to RCC log on UART

export PATH=:/proc/boot:/sbin:/bin:/usr/bin:/usr/sbin:/net/mmx/bin:/net/mmx/usr/bin:/net/mmx/usr/sbin:/net/mmx/sbin:/net/mmx/mnt/app/armle/bin:/net/mmx/mnt/app/armle/sbin:/net/mmx/mnt/app/armle/usr/bin:/net/mmx/mnt/app/armle/usr/sbin
export LD_LIBRARY_PATH=/net/mmx/mnt/app/root/lib-target:/net/mmx/mnt/eso/lib:/net/mmx/eso/lib:/net/mmx/mnt/app/usr/lib:/net/mmx/mnt/app/armle/lib:/net/mmx/mnt/app/armle/lib/dll:/net/mmx/mnt/app/armle/usr/lib
export IPL_CONFIG_DIR=/etc/eso/production

#GLOBALS
XXD="${2}/apps/sbin/xxd" # not on any unit
TEE="${2}/apps/sbin/tee" # /net/mmx/usr/bin
#BC="${2}/apps/sbin/bc" # /net/mmx/mnt/app/armle/usr/bin
SED="${2}/apps/sbin/sed" # /net/mmx/mnt/app/armle/usr/bin
DD="${2}/apps/sbin/dd" # /net/mmx/bin
PC="${2}/apps/sbin/pc" # /net/mmx/mnt/app/eso/bin/apps/pc
LOG="${2}/backup/logs/launcher_log.txt"

mount -uw ${2}
touch $LOG 2>> $LOG

echo "[stuffScript] Cool stuff found and executing..." | $TEE -a $LOG

#Remove Swdlautorun.txt from SD to avoid update loop
mv -f ${2}/Swdlautorun.txt ${2}/_Swdlautorun.txt 2>> $LOG
echo "-- Swdlautorun.txt disabled" | $TEE -a $LOG

# prevent MOST popup...
mount -uw /net/rcc/mnt/efs-persist
touch /net/rcc/mnt/efs-persist/SWDL/skipMostPopup.txt
echo "-- Skip MOST enabled" | $TEE -a $LOG

#Clear illeagl and withdrawn FECs
rm -f /net/rcc/mnt/efs-persist/FEC/IllegalFecContainer.fec 2>> $LOG
rm -f /net/rcc/mnt/efs-persist/FEC/WithdrawnFecContainer.fec 2>> $LOG
echo "-- Illegal and withdrawn FECs removed" | $TEE -a $LOG

# do some cleanup...
mount -uw /net/rcc/mnt/efs-persist
rm -rf /net/rcc/mnt/efs-persist/SWDL/*.old
rm -rf /net/rcc/mnt/efs-persist/SWDL/Log/service/*
rm -rf /net/rcc/mnt/efs-persist/SWDL/FileCopyInfo/Launcher.info
rm -rf /net/rcc/mnt/efs-persist/SWDL/MainUnit-version2.txt.SWDL.compatibility.txt
echo "-- Cleanup done!" | $TEE -a $LOG

# update GEM --> 4.12 to run M.I.B
mount -uw /net/mmx/mnt/app
checksum0="43024c7ba4c452fc0bda70c9cd91adb28027d494" #GEM4.12
checksum1="3725aad3ed38cd72a132e76908db43b9f49dd19c" #GEM3.4
checksum2="017bb1a07c18b671beb0ec1cb66c5f736a9af8ff" #GEM3.5
checksum3="0ebe8b0226b27fd9f5124cc406559c5fe84d6e34" #GEM3.6 - e.g. K2161
checksum4="ae2645648d0a8dec1500af9df21fc556d91f25d2" #GEM4.0 - e.g. K2589

if [ -f /net/mmx/mnt/app/eso/hmi/lsd/jars/AppDevelopment.jar ]; then
	GEMJAR="AppDevelopment.jar"
	echo "AppDevelopment.jar found" | $TEE -a $LOG
	elif [ -f /net/mmx/mnt/app/eso/hmi/lsd/jars/GEM.jar ]; then
		GEMJAR="GEM.jar"
    echo "GEM.jar found"
	else
		echo "*.jar not found" | $TEE -a $LOG
fi

if [ -n "$GEMJAR" ]; then
	checksum_unit="$(/net/rcc/usr/bin/sha1sum /net/mmx/mnt/app/eso/hmi/lsd/jars/$GEMJAR | awk '{print $1}')" 2>> $LOG
	if [ $checksum1 = $checksum_unit ] || [ $checksum2 = $checksum_unit ] || [ $checksum3 = $checksum_unit ] || [ $checksum4 = $checksum_unit ]; then
		echo "GEM <4.11 found" | $TEE -a $LOG
		echo "M.I.B can not run on this version!" | $TEE -a $LOG
		echo "Upgrading now :)" | $TEE -a $LOG
		mount -uw /net/mmx/mnt/app/
		on -f mmx cp -r /net/mmx/mnt/app/eso/hmi/lsd/jars/$GEMJAR /net/mmx/mnt/app/eso/hmi/lsd/jars/backup_"$GEMJAR" 2>> $LOG
		on -f mmx cp -r ${2}/mod/gem/GEM412 /net/mmx/mnt/app/eso/hmi/lsd/jars/$GEMJAR  2>> $LOG #GEM4.12
		echo "-- GEM replaced. DONE" | $TEE -a $LOG
	else
		echo "-- GEM version OK - no update needed" | $TEE -a $LOG
	fi
fi

# add M.I.B. to GEM
on -f mmx rm -rf /eso/hmi/engdefs/z_Launcher-sda0.esd
on -f mmx ln -s /net/mmx/fs/sda0/esd/Launcher-sda0.esd /eso/hmi/engdefs/z_Launcher-sda0.esd 2>> $LOG
echo "-- M.I.B GEM link installed" | $TEE -a $LOG

# GEM ON
mount -uw /net/mmx/mnt/app
on -f mmx ${2}/apps/sbin/pc b:0:3221356557:0 1 2>> $LOG
on -f mmx ${2}/apps/sbin/pc b:0:1 0 2>> $LOG
echo "-- Development Mode - GEM - activated" | $TEE -a $LOG

# install sshd when it is on SD
if [ -d ${2}/Toolbox/ ]; then
	on -f mmx ${2}/Toolbox/scripts/sshd_install.sh
	echo "-- sshd is now installed..." | $TEE -a $LOG
fi

# run individual scripts
mount -uw ${2}
if [ -f ${2}/mod/command.sh ]; then
	. ${2}/mod/command.sh
	echo "-- individual scripts done!" | $TEE -a $LOG
fi

sync; sync; sync

echo "[stuffScript] DONE\n\n" | $TEE -a $LOG
