#!/bin/ksh

# change this file to run any command, script or binary from SD
# no need to touch metainfo2.txt as this is outside of its reach
# final script run time is set to 300s in metainfo2.txt
# if you need more time extend FinalScriptMaxTime = XX
# add echo to output debugging information to RCC log on UART

. /net/mmx/fs/sda0/config/BASICS

echo -ne "[stuffScript] Cool stuff found and executing...\n" | $TEE -i -a $LOG

export GEM=1
export SWDLAUTORUN=1 # allows Swdlautorun.txt in root of SD during SWDL process

echo -ne "\n--- Load PNG to display during finalscript --\n" | $TEE -i -a $LOG
${2}/apps/showimage -load 0 ${2}/mod/images/showimage/ finalscript.png SWDL
echo -ne "\n--- Running basic backup --------------------\n" | $TEE -i -a $LOG
${2}/apps/backup -b
echo -ne "\n--- Running Launcher script -----------------\n" | $TEE -i -a $LOG
${2}/apps/launcher -all
echo -ne "\n--- Unload PNG ------------------------------\n" | $TEE -i -a $LOG
${2}/apps/showimage -unload

echo -ne "[stuffScript] Cool stuff DONE\n" | $TEE -i -a $LOG
