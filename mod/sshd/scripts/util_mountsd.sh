# MIB2 script, part of the MIB High toolbox.
# Coded by Jille
# This script will determine if an SD is inserted, and call to mount it.

#Is there any SD-card inserted?
if [[ -d /net/mmx/fs/sda0 ]]
then
    echo SDA0 found
    export VOLUME=/net/mmx/fs/sda0
elif [[ -d /net/mmx/fs/sdb0 ]]
then
    echo SDB0 found
    export VOLUME=/net/mmx/fs/sdb0
else 
    echo No SD-cards found.
    exit 0
fi

echo Mounting SD-card.
mount -uw $VOLUME

sleep .5