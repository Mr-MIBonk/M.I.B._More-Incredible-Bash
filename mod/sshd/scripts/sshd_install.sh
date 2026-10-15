#!/bin/sh
export PATH=/net/mmx/proc/boot:/net/mmx/bin:/net/mmx/usr/bin:/net/mmx/usr/sbin:/net/mmx/sbin:/net/mmx/mnt/app/media/gracenote/bin:/net/mmx/mnt/app/armle/bin:/net/mmx/mnt/app/armle/sbin:/net/mmx/mnt/app/armle/usr/bin:/net/mmx/mnt/app/armle/usr/sbin:$PATH

if [ "$_" = "/bin/on" ]; then BASE="$0"; else BASE="$_"; fi
SCRIPTDIR=$( cd -P -- "$(dirname -- "$(command -v -- "$BASE")")" && pwd -P )

SSD_INSTALL_DIR="/net/mmx/mnt/app/eso/hmi/engdefs/scripts/ssh"

export LD_LIBRARY_PATH=/net/mmx/mnt/app/root/lib-target:/net/mmx/eso/lib:/net/mmx/mnt/app/usr/lib:/net/mmx/mnt/app/armle/lib:/net/mmx/mnt/app/armle/lib/dll:/net/mmx/mnt/app/armle/usr/lib
export PATH=${SCRIPTDIR}:${SSD_INSTALL_DIR}/usr/bin:${SSD_INSTALL_DIR}/usr/sbin:$PATH

. ${SCRIPTDIR}/util_mountsd.sh
if [[ -z "$VOLUME" ]] 
then
  echo "No SD-card found, quitting"
  exit 0
fi

PUB_KEY_PATH="${VOLUME}/Custom/id_rsa.pub"
SSHD_APP="${VOLUME}/mod/sshd"


# Make it writable
mount -uw /net/mmx/mnt/app
mount -uw /net/mmx/mnt/system

mkdir -p ${SSD_INSTALL_DIR}/etc

cp -prv ${SSHD_APP}/etc/* ${SSD_INSTALL_DIR}/etc/
cp -prv ${SSHD_APP}/usr ${SSD_INSTALL_DIR}/
chmod 755 ${SSD_INSTALL_DIR}/usr/bin/*
chmod 755 ${SSD_INSTALL_DIR}/usr/sbin/*
sed -ir 's:\r$::g' ${SSD_INSTALL_DIR}/usr/sbin/start_sshd
sed -ir 's:\r$::g' ${SSD_INSTALL_DIR}/etc/banner.txt

if [ -f ${PUB_KEY_PATH} ]; then
  mkdir -p /net/mmx/mnt/app/root/.ssh
  chmod 600 /net/mmx/mnt/app/root/.ssh
  chmod 644 /net/mmx/mnt/app/root
  cp -prv ${PUB_KEY_PATH} /net/mmx/mnt/app/root/.ssh/authorized_keys
  chmod 644 /net/mmx/mnt/app/root/.ssh/authorized_keys
  echo "SSH public key installed from ${PUB_KEY_PATH} > /net/mmx/mnt/app/root/.ssh/authorized_keys"
else
  echo "SSH public key not at SD/Custom/id_rsa.pub - password login only"
fi

echo "Adding paths to /net/mmx/mnt/app/root/.profile"
echo "export PATH=${PATH}" > /net/mmx/mnt/app/root/.profile
echo "export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}" >> /net/mmx/mnt/app/root/.profile

echo "PS1='\${USER}@mmx:\${PWD}> '" >> /net/mmx/mnt/app/root/.profile
echo "export PS1" >> /net/mmx/mnt/app/root/.profile


echo "Copy scp wrapper"
cp ${SSHD_APP}/scp_wrapper /net/mmx/mnt/app/root/scp
chmod 755 /net/mmx/mnt/app/root/scp
sed -ir 's:\r$::g' /net/mmx/net/mmx/mnt/app/root/scp

if [ ! -f ${SSD_INSTALL_DIR}/etc/ssh_host_dsa_key ]; then
  ssh-keygen -t dsa -N '' -f ${SSD_INSTALL_DIR}/etc/ssh_host_dsa_key
fi
if [ ! -f ${SSD_INSTALL_DIR}/etc/ssh_host_rsa_key ]; then
  ssh-keygen -t rsa -N '' -f ${SSD_INSTALL_DIR}/etc/ssh_host_rsa_key -b 1024
fi
if [ ! -f ${SSD_INSTALL_DIR}/etc/ssh_host_key ]; then
  ssh-keygen -t rsa -N '' -f ${SSD_INSTALL_DIR}/etc/ssh_host_key -b 1024
fi

# Manually start the sshd server (you need to specify the full path):
# on -f mmx slay -v inetd
# on -f mmx ${SSD_INSTALL_DIR}/usr/sbin/sshd -ddd -f ${SSD_INSTALL_DIR}/etc/sshd_config
# If something isn't working start the server with debug output enabled and the problem should become obvious: /usr/sbin/sshd -ddd

if [ ! -f /net/mmx/mnt/system/etc/inetd.conf.bu ]; then
	cp -pv /net/mmx/mnt/system/etc/inetd.conf /net/mmx/mnt/system/etc/inetd.conf.bu
fi
echo "Adding config to automatically start sshd from inetd"
# Remove any existing lines for sshd
sed -i -r 's:^.*sshd.*\n*::p' /net/mmx/mnt/system/etc/inetd.conf
# Add new command for sshd
echo "ssh        stream tcp nowait root ${SSD_INSTALL_DIR}/usr/sbin/start_sshd in.sshd" >> /net/mmx/mnt/system/etc/inetd.conf

# Open up sshd port in firewall
echo "Add firewall configuration"
for PF in /net/mmx/mnt/system/etc/pf*.conf ; do
  if [ ! -f ${PF}.bu ]; then
    cp -pv ${PF} ${PF}.bu
  fi
  cp -p ${PF}.bu ${PF}

  # Insert suitable firewall rules just under the "allow dns" section
  # These often need to be in the same part of the config file as the other "allow" lines, doesn't always work appended to the end of the file.
  sed -i -r 's:^(.* port domain keep .*)$:\1\n\n# SSH Access:' "${PF}"
  
  if grep -q '\$dbg_if' ${PF}; then
    sed -i -r 's:^(# SSH Access)$:\1\npass in quick on \$dbg_if proto tcp from any to (\$dbg_if) port 22 keep state allow-opts:' "${PF}"
  fi
  if grep -q '\$wlan_if' ${PF}; then
    sed -i -r 's:^(# SSH Access)$:\1\npass in quick on \$wlan_if proto tcp from any to (\$wlan_if) port 22 keep state allow-opts:' "${PF}"
  fi
  if grep -q '\$ext_if' ${PF}; then
    sed -i -r 's:^(# SSH Access)$:\1\npass in quick on \$ext_if proto tcp from any to (\$ext_if) port 22 keep state allow-opts:' "${PF}"
  fi
  if grep -q '\$ppp_if' ${PF}; then
    sed -i -r 's:^(# SSH Access)$:\1\npass in quick on \$ppp_if proto tcp from any to (\$ppp_if) port 22 keep state allow-opts:' "${PF}"
  fi
  
  echo "Updated ${PF}"
done
if [ -f /net/mmx/mnt/system/etc/pf.mlan0.conf ]; then
  /net/mmx/mnt/app/armle/sbin/pfctl -F all -f /net/mmx/mnt/system/etc/pf.mlan0.conf
  echo "Reloaded ${PF} with wlan rules."
fi

echo "Restart inetd"
slay -v inetd
sleep 1
inetd

# Make readonly again
mount -ur /net/mmx/mnt/app
mount -ur /net/mmx/mnt/system

echo Done.

exit 0