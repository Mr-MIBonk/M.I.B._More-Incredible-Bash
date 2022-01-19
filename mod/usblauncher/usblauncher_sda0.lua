-- ASIX AX88179
device(0x0b95, 0x1790) {
    driver"/etc/scripts/extnet.sh -oname=en,lan=0,busnum=$(busno),devnum=$(devno),wait=60,ign_remove,path=$(USB_PATH) /lib/dll/devnp-asix.so /dev/io-net/en0";
    removal"ifconfig en0 destroy";
};

-- ASIX AX88772
device(0x0b95, 0x7720) {
    driver"/etc/scripts/extnet.sh -oname=en,lan=0,busnum=$(busno),devnum=$(devno),wait=60,ign_remove,path=$(USB_PATH) /lib/dll/devnp-asix.so /dev/io-net/en0";
    removal"ifconfig en0 destroy";
};

-- ASIX AX88772
device(0x0b95, 0x772a) {
    driver"/etc/scripts/extnet.sh -oname=en,lan=0,busnum=$(busno),devnum=$(devno),wait=60,ign_remove,path=$(USB_PATH) /lib/dll/devnp-asix.so /dev/io-net/en0";
    removal"ifconfig en0 destroy";
};

-- ASIX AX88772B
device(0x0b95, 0x772b) {
    driver"/etc/scripts/extnet.sh -oname=en,lan=0,busnum=$(busno),devnum=$(devno),wait=60,ign_remove,path=$(USB_PATH) /lib/dll/devnp-asix.so /dev/io-net/en0";
    removal"ifconfig en0 destroy";
};

-- ASIX AX88772C
device(0x0b95, 0x772c) {
    driver"/etc/scripts/extnet.sh -oname=en,lan=0,busnum=$(busno),devnum=$(devno),wait=60,ign_remove,path=$(USB_PATH) /lib/dll/devnp-asix.so /dev/io-net/en0";
    removal"ifconfig en0 destroy";
};

