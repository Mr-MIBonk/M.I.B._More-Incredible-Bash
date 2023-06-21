#!/bin/ksh

# change this file to run any command, script or binary from SD
# no need to touch metainfo2.txt as this is outside of its reach
# final script run time is set to 300s in metainfo2.txt
# if you need more time extend FinalScriptMaxTime = XX
# add echo to output debugging information to RCC log on UART

echo "[stuffScript] Cool stuff found and executing..."

export GEM=1
export SWDLAUTORUN=1 # allows Swdlautorun.txt in root of SD during SWDL process

echo "load PNG to display during finalscript --"
${2}/apps/showimage -load 0 ${2}/mod/images/showimage/ finalscript.png SWDL&
sleep 10 # to avaoid a parallel run of LOGS
echo "Running basic backup --------------------"
${2}/apps/backup -b
echo "Running Launcher script -----------------"
${2}/apps/launcher -all
echo "unload PNG ------------------------------"
${2}/apps/showimage -unload

echo "[stuffScript] Cool stuff DONE"
