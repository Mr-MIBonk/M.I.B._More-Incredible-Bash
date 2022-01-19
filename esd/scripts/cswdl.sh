#!/bin/sh

# esd cswdlsh v0.2.0 (2021-10-01 by MIBonk)

trap '' 2

export PATH=.:/proc/boot:/bin:/usr/bin:/usr/sbin:/sbin:/mnt/app/media/gracenote/bin:/mnt/app/armle/bin:/mnt/app/armle/sbin:/mnt/app/armle/usr/bin:/mnt/app/armle/usr/sbin
export LD_LIBRARY_PATH=/lib:/mnt/app/root/lib-target:/eso/lib:/mnt/app/usr/lib:/mnt/app/armle/lib:/mnt/app/armle/lib/dll:/mnt/app/armle/usr/lib
unset LD_PRELOAD

echo -ne "M.I.B. - More Incredible Bash "
cat /net/mmx/fs/sda0/VERSION
echo "NOT FOR COMMERCIAL USE - IF YOU BOUGHT THIS YOU GOT RIPPED OFF"
echo ""
echo "NOTE: NEVER interrupt the process with -Back- button or removing SD Card!!!"
echo "CAUTION: Ensure that a external power is connected to the car on during any"
echo "flash or programming process! Power failure during flasing/programming will"
echo "brick your unit! - All you do and use at your own risk!"
echo ""

echo "run some SWDL cleanup"
mount -uw /net/rcc/mnt/efs-persist
#Clears stuck FW updates
echo "Clears '1556 - Internal Control Module Memory Check Sum Error' from 5F"
echo "Removes remnants from FW updates (e.g. update.txt*, illegal/withdrawn FEC)"
rm -rf /net/rcc/mnt/efs-persist/SWDL/update.txt
rm -rf /net/rcc/mnt/efs-persist/SWDL/update.txt.Abort.old
rm -rf /net/rcc/mnt/efs-persist/SWDL/update.txt.CancelImport
rm -rf /net/rcc/mnt/efs-persist/SWDL/update.txt.backup
rm -rf /net/rcc/mnt/efs-persist/SWDL/update.txt.End.old
rm -rf /net/rcc/mnt/efs-persist/SWDL/MainUnit-version2.txt
rm -rf /net/rcc/mnt/efs-persist/SWDL/MainUnit-version2.txt.SWDL.compatibility.txt
rm -rf /net/rcc/mnt/efs-persist/SWDL/MainUnit-version2.txt.SWDL.version.txt
rm -rf /net/rcc/mnt/efs-persist/SWDL/MainUnit-version2.txt.SWDL.checkPointCrc.txt.z
rm -rf /net/rcc/mnt/efs-persist/FEC/IllegalFecContainer.fec
rm -rf /net/rcc/mnt/efs-persist/FEC/WithdrawnFecContainer.fec
echo ""
echo "All done! now you can go back..."
echo "Reboot unit manually to apply changes"

return 2> /dev/null

trap 2

exit 0

