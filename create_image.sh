#!/bin/bash

	sudo apt-get update
	sudo DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential libncurses5-dev gcc make git bc libssl-dev libelf-dev libreadline-dev binutils-dev libnl-genl-3-dev make trace-cmd
	sudo DEBIAN_FRONTEND=noninteractive apt-get install -y flex bison

path=`realpath $0`
path=`dirname $path`

echo "git clone 18.04 bionic"
git clone git://kernel.ubuntu.com/ubuntu/ubuntu-bionic.git --depth=1 --branch=v5.0
[ ! "$?" -eq "0" ] && exit 1

cd ubuntu-bionic

echo "cp .config"
udo cp /boot/config-`uname -r` .config
sudo chown `whoami` .config

echo "apply patches"
git checkout -b 'v5.0'
git config --global user.email "build@example.com"
git config --global user.name  "Build VM"

git am -3 $path/*.patch

#LSMOD=$path/lsmod
#dont exclude network related modules we might need
#scripts/kconfig/streamline_config.pl > modconfig
#[ ! "$?" -eq "0" ] && exit 4
#mv modconfig .config
./scripts/config --enable CONFIG_KASAN
make olddefconfig
[ ! "$?" -eq "0" ] && exit 1
./scripts/config --disable CONFIG_XFS_ONLINE_SCRUB
./scripts/config --disable KASAN_EXTRA
./scripts/config --enable CONFIG_KASAN_OUTLINE

#make localmodconfig

#echo "build image"
#cp ./debian/scripts/retpoline-extract-one ./scripts/ubuntu-retpoline-extract-one

#echo "initramfs dep"
#sudo sed -i 's/most/dep/g' /etc/initramfs-tools/initramfs.conf

#removing noise we dont need from 3rd party drivers
#sed -i 's/obj-y/obj-n/g' ubuntu/Makefile

#make -j `nproc` LOCALVERSION=-cbn > /dev/null
make -j `nproc` #> /dev/null
[ ! "$?" -eq "0" ] && exit 2

echo "install image"
sudo DEBIAN_FRONTEND=noninteractive make modules_install install
#sudo DEBIAN_FRONTEND=noninteractive make INSTALL_MOD_STRIP=1 modules_install install
[ ! "$?" -eq "0" ] && exit 3

#exit

echo 'configuring grub'
#sudo sh -c 'echo GRUB_CMDLINE_LINUX=\"\$GRUB_CMDLINE_LINUX threadirqs\" >> /etc/default/grub.d/50-cloudimg-settings.cfg'
#sudo sh -c 'echo GRUB_CMDLINE_LINUX=\"\$GRUB_CMDLINE_LINUX threadirqs\" >> /etc/default/grub'

#string='cbn'
#STR=`sudo grep gnulinux /boot/grub/grub.cfg |grep -v recovery|grep $string|awk '{print $(NF-1)}'`
#echo $STR
#sudo sed -i "s/GRUB_DEFAULT=.*/GRUB_DEFAULT=$STR/" /etc/default/grub
#sudo sed -i "s/GRUB_DEFAULT=.*/GRUB_DEFAULT=$STR/" /etc/default/grub.d/50-cloudimg-settings.cfg
sudo sh -c 'echo GRUB_DISABLE_RECOVERY="true" >> /etc/default/grub'
sudo sh -c 'echo GRUB_DISABLE_SUBMENU=y >> /etc/default/grub'
sudo update-grub2
echo "done with image kernel creation"


