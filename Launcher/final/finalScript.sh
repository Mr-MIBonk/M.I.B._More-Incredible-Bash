#!/bin/ksh

echo [finalScript] for HW ${1} on medium ${2}...

# load cool stuff...
if [ -f ${2}/Launcher/stuff.sh ]; then
	/bin/ksh ${2}/Launcher/stuff.sh ${1} ${2}
else
	# Report error because stuff.sh is not found
	echo "error no install script found"
fi

echo "[finalScript] finished"

touch /tmp/SWDLScript.Result

