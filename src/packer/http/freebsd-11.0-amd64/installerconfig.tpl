export nonInteractive=yes
export ZFSBOOT_POOL_NAME=z
export ZFSBOOT_VDEV_TYPE=stripe
export ZFSBOOT_DISKS=vtbd0
export ZFSBOOT_POOL_CREATE_OPTIONS='-O compress=lz4 -O atime=off -O checksum=fletcher4'
export DISTRIBUTIONS='base.txz kernel.txz lib32.txz'

#!/bin/sh
echo "PROVISIONING_PASSWORD" | pw usermod root -h 0
mkdir /root/pkgs

sysrc ifconfig_vtnet0=dhcp
sysrc ifconfig_em0=dhcp
sysrc sshd_enable=yes
echo 'PermitRootLogin yes' > /etc/ssh/sshd_config

shutdown -r now
