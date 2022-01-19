# M.I.B. - More Incredible Bash

![GEM](https://github.com/Mr-MIBonk/M.I.B._More-Incredible-Bash/blob/main/GEM.png)

## NOTE:
- M.I.B. is running on Harman MHI2(Q) units (MIB 2.x) only.
- Minimum requirement to run M.I.B. in GEM is GEM version 4.1+.
- This excludes some of the older train versions.
- Use M.I.B. via Putty on older GEM versions or update FW to latest available, they are all GEM 4.1+.

- Make sure, that you always run latest M.I.B version --> https://mib.mibsolution.one
- For additional Information check https://mibwiki.one

## CAUTION:
- Ensure that a external power is connected to the car during any flash or programming process!
- It is not recommended to flash with running engine!
- Power failure during flasing/programming will brick your unit.
- All you do and use at your own risk!

## Prepare SD card:
- Extract all files of the M.I.B. to the root directory of a clean SD-Card (FAT32 formatted is requirement!!!)
- Make sure that your SD card is not write protected.
- Patched IFS-stage2 images have to be placed on the SD card in the folder /patches
- Pre-patched (CP, FEC and EL) ifs-root-stage2 images can be found for all recent MHI2 FW versions here: https://mib.mibsolution.one
- You only have to copy the folder(s) you need for your car(s) - e.g. /patches/MHI2_ER_SKGxx_Pxxxx_MUxxxx_PATCH  
- They are already prepared in the right way, so that the tool can use them right away
- In case you want to use your own patches (not recommended) - ask us first to help you:
- For each SW-train a seperate folder is needed e.g. /patches/MHI2_ER_SKGxx_Pxxxx_MUxxxx_PATCH
- The folder has to contain the patched ifs-root-stage2 image with the following naming syntax:
- "MU-version"-ifs-root-part2-"image start address in hex within RCC"-"image length in hex" --> e.g. MUxxxx-ifs-part2-0x00ba0000-1C06F300.ifs 
- image length is on byte 0x20 position 04-07 in little Endian of the original ifs-root-stage2 image (e.g. fresh from FW update)
- addfec.txt with the FECs you want to add to your FecContainer.fec and stock ExceptionList.txt. Get these from any of the other prepared patch folder.
### FEC Generator:
-  M.I.B is generating custom FecContainer.fec files based on existing FecContainer.fec and addfec.txt in patch folder.
- addfec.txt can be edited with any ASCII editor (Notepad++). Only not yet existing FECs will be added to container during the process.
- No need to change FECContainer.fec with WhatTheFec tool. Original FECs in container will continue to work even without patch on unit.
- It is recommended to switch to this method and replace existing ExceptionList.txt with original (empty) versions.
- Just run "Add new Fecs to FecContainer.fec" script in M.I.B -> PATCH.
### M.I.B. in Green Engineering Menu - GEM:
- Insert the SD card into slot SD1 of your MHI2 unit.
- Enter Engineering/Red Menu to start SW Update. Select UPDATE, select SD card, select "M.I.B. Launcher V1.0", START update.
- Installtion of M.I.B. on your Unit will start. The unit will restart three time until update process is finished.
- GEM will be activated as part of the installation.
- SVM error has to be cleared via M.I.B. function in GEM after installation
-  Enter GEM on your unit and have FUN! 
- Select ==>>M.I.B.-More_Incredible_Bash<<==
- Check GEM_menu_structure.png for details on the existing menus and function.
  
### NOTE: SD card has to be placed in unit (SD1) to enable M.I.B. in GEM. --> no SD no M.I.B.
- GEM screen layout is fitted to 9.2'' screens - should work OK on 8'', but will have text cutted on smaller than 8''

### Update to new M.I.B. version:
- No need to reinstall M.I.B if you want to use a new version.
- Just create a fresh SD with latest M.I.B. version and insert into unit.

----------------------------------------------------------------------------------------------------------------------------------------

## 2nd way, D-Link Method: Connect to MHI2 and start M.I.B.:
-  D-Link - e.g. DUB-E100 HW rev. D1 - USB-Ethernet adapter is required to connect to your MHI2 unit.
-  Use Putty/Kitty to connect via UART or Telnet (MIB IP:172.16.250.248) and login into RCC (recommended: port:123) or MMX (port:23).
-  Login and password for your units SW train has to be known.
- Check your SW-train, a pre-patched ifs-root-stage2 has to be present within the folder /patches
- Insert the SD card into slot SD1 of your MHI2 unit and login to the RCC shell:
#### Mount SD card in slot SD1
- mount -uw /net/mmx/fs/sda0/
#### start M.I.B by typing
- /net/mmx/fs/sda0/start

- Default screen seize of Putty/Kitty is often too small to display the M.I.B. menu in full.
- Increase the window seize manually.

You should see (a more colourful) menu with the following content:

![bash](https://github.com/Mr-MIBonk/M.I.B._More-Incredible-Bash/blob/main/bash.png)

******************************************************************************************************************************************

**	0 - Advanced Backup
- Runs a full backup (RCC, MMX, EEPROM, ...) of your unit and places it into the folder /backup/"your hardware ID"

**	1 - VIM patch (199 km/h)
- Writes custom Video In Motion (VIM) speed of 199 km/h (yes, too slow for German Autobahn) to your unit
- Unit will automatically restart to save changes permanently

**	2 - VIM Original (6 km/h)
- Writes factory default Video In Motion (VIM) speed to unit
- Unit will automatically restart to save changes permanently

**	3 - IFS-ROOT-Stage2 flash patched image
- Will create a backup if it was not already created before
- applies patched IFS Stage 2 image - containing patched MIBRoot - to the unit
- Copy FEC and EL List to Unit - like option 5
- Unit will automatically restart to save changes permanently

**	4 - IFS-ROOT-Stage2 revert to Backup image
- Applies original IFS Stage 2 image - containing original/stock MIBRoot - from your system backup to the unit
- Unit will automatically restart to save changes permanently

**	5 - Copy FEC and EL List to Unit
- Copies ExceptionList.txt and/or FecContainer.fec placed within 
- e.g. /patches/MHI2_ER_SKGxx_Pxxxx_MUxxxx_PATCH to the unit
- if no FEC and/or EL is inside /patch directory, files from /backup folder will be used

**	6 - Developer Menu activation
- Developer Menu will be enabled - no need for VCP/VCDS or OBD11 ;)
- Unit will automatically restart to save changes permanently

**	7 - CarPlay & Android Auto activation
- Coding adaption channels for CP & AA as well as USB with iPhone support
- with this, all you need for Carplay is coded, you never need some other coding tools ;-)

**	8 - Ambient Light Buttons Original
- it is some special coding only for Skoda Octavia 5E, yet!

**	9 - Ambient Light Buttons patch (first, set to Original)
- it is some special coding only for Skoda Octavia 5E, yet!

**	F - Fix SVM error
- Fix SVM Fault on Unit

**	G - Install M.I.B. in GEM
- Install M.I.B. for use in GEM on Unit

**	O - Set OBD Status
- Prevent Unit from OBD

**	U - Mount USB writeable
- makes USB devices writeable

**	W - Mountpoints writeable
- make some Mounts writeable on the unit

**	R - Reboot Unit
- restart the Unit

**	C - cleanup Logs
- delete all inside /log directory

**	S - show Log (press Q for exit view)
- show all our Logs from this Unit

**	H - Help
- this here...

**	L - GPL License
- please take a look and note our license

******************************************************************************************************************************************

### CONTACT:
- mailto: Mr.MIBonk@gmail.com
- Telegram Channel: https://t.me/joinchat/EHt4RRksHcMQk6Xi6tFaBw
- Wiki: https://mibwiki.one
- Get in contact with us to get support and provide feedback about M.I.B.

### Supporting Documents:
https://mibsolution.one

user and pass: guest
