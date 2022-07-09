#!/bin/ksh

# change this file to run any command, script or binary from SD
# no need to touch metainfo2.txt as this is outside of its reach
# final script run time is set to 300s in metainfo2.txt
# if you need more time extend FinalScriptMaxTime = XX
# add echo to output debugging information to RCC log on UART

echo "[stuffScript] Cool stuff found and executing..."

export GEM=1
export SWDLAUTORUN=1 # allows Swdlautorun.txt in root of SD during SWDL process

echo "Runnung basic backup --------------------"
${2}/apps/backup -b
echo "Runnung AIO script ----------------------"
${2}/apps/launcher -all

echo "[stuffScript] Cool stuff DONE"
