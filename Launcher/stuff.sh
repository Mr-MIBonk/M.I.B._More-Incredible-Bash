#!/bin/ksh

# change this file to run any command, script or binary from SD
# no need to touch metainfo2.txt as this is outside of its reach
# final script  run time is set to 30s in metainfo2.txt
# if you need more time extend FinalScriptMaxTime = XX
# add echo to output debugging information to RCC log on UART

export PATH=:/proc/boot:/sbin:/bin:/usr/bin:/usr/sbin:/net/mmx/bin:/net/mmx/usr/bin:/net/mmx/usr/sbin:/net/mmx/sbin:/net/mmx/mnt/app/armle/bin:/net/mmx/mnt/app/armle/sbin:/net/mmx/mnt/app/armle/usr/bin:/net/mmx/mnt/app/armle/usr/sbin
export LD_LIBRARY_PATH=/net/mmx/mnt/app/root/lib-target:/net/mmx/mnt/eso/lib:/net/mmx/eso/lib:/net/mmx/mnt/app/usr/lib:/net/mmx/mnt/app/armle/lib:/net/mmx/mnt/app/armle/lib/dll:/net/mmx/mnt/app/armle/usr/lib
export IPL_CONFIG_DIR=/etc/eso/production

echo "[finalScript] cool stuff found and executing..."

# prevent MOST popup...
mount -uw /net/rcc/mnt/efs-persist
touch /net/rcc/mnt/efs-persist/SWDL/skipMostPopup.txt

# do some cleanup...
mount -uw /net/rcc/mnt/efs-persist
rm -rf /net/rcc/mnt/efs-persist/SWDL/*.old
rm -rf /net/rcc/mnt/efs-persist/SWDL/Log/service/*
rm -rf /net/rcc/mnt/efs-persist/SWDL/FileCopyInfo/Launcher.info
rm -rf /net/rcc/mnt/efs-persist/SWDL/MainUnit-version2.txt.SWDL.compatibility.txt
echo "cleanup is done!"

# update GEM --> 4.12 to run M.I.B
mount -uw /net/mmx/mnt/app
checksum0="43024c7ba4c452fc0bda70c9cd91adb28027d494" #GEM4.12
checksum1="3725aad3ed38cd72a132e76908db43b9f49dd19c" #GEM3.4
checksum2="017bb1a07c18b671beb0ec1cb66c5f736a9af8ff" #GEM3.5
checksum3="0ebe8b0226b27fd9f5124cc406559c5fe84d6e34" #GEM3.6 - e.g. K2161
checksum4="ae2645648d0a8dec1500af9df21fc556d91f25d2" #GEM4.0 - e.g. K2589

if [ -f /net/mmx/mnt/app/eso/hmi/lsd/jars/AppDevelopment.jar ]; then
	GEMJAR="AppDevelopment.jar"
	echo "AppDevelopment.jar found"
	elif [ -f /net/mmx/mnt/app/eso/hmi/lsd/jars/GEM.jar ]; then
		GEMJAR="GEM.jar"
    echo "GEM.jar found"
	else
		echo "*.jar not found"
fi

if [ -n "$GEMJAR" ]; then
	checksum_unit="$(/net/rcc/usr/bin/sha1sum /net/mmx/mnt/app/eso/hmi/lsd/jars/$GEMJAR | awk '{print $1}')"
	if [ $checksum1 = $checksum_unit ] || [ $checksum2 = $checksum_unit ] || [ $checksum3 = $checksum_unit ] || [ $checksum4 = $checksum_unit ]; then
		echo "GEM <4.11 found"
		echo "M.I.B can not run on this version!"
		echo "Upgrading now :)"
		mount -uw /net/mmx/mnt/app/
		on -f mmx cp -r /net/mmx/mnt/app/eso/hmi/lsd/jars/$GEMJAR /net/mmx/mnt/app/eso/hmi/lsd/jars/backup_"$GEMJAR"
		on -f mmx cp -r ${2}/mod/gem/GEM412 /net/mmx/mnt/app/eso/hmi/lsd/jars/$GEMJAR #GEM4.12
		echo "GEM replaced. DONE"
	fi
fi

# add M.I.B. to GEM
on -f mmx rm -rf /eso/hmi/engdefs/z_Launcher-sda0.esd
on -f mmx ln -s /net/mmx/fs/sda0/esd/Launcher-sda0.esd /eso/hmi/engdefs/z_Launcher-sda0.esd
echo "GEM Link now installed!"

# GEM ON
mount -uw /net/mmx/mnt/app
on -f mmx ${2}/apps/sbin/pc b:0:3221356557:0 1
on -f mmx ${2}/apps/sbin/pc b:0:1 0
echo "GEM now activated!"

# install sshd when it is on SD
if [ -d ${2}/Toolbox/ ]; then
	on -f mmx ${2}/Toolbox/scripts/sshd_install.sh
	echo "sshd is now installed..."
fi

# run individual scripts
mount -uw ${2}
if [ -f ${2}/mod/command.sh ]; then
	. ${2}/mod/command.sh
	echo "individual scripts done!"
fi

sync; sync; sync

echo "[finalScript] all you need is installed now!"
