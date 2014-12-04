#!/bin/sh

# Colorize and add text parameters
red=$(tput setaf 1) # red
grn=$(tput setaf 2) # green
cya=$(tput setaf 6) # cyan
txtbld=$(tput bold) # Bold
bldred=${txtbld}$(tput setaf 1) # red
bldgrn=${txtbld}$(tput setaf 2) # green
bldblu=${txtbld}$(tput setaf 4) # blue
bldcya=${txtbld}$(tput setaf 6) # cyan
txtrst=$(tput sgr0) # Reset

export KERNELDIR=`readlink -f .`
export PARENT_DIR=`readlink -f ..`
export INITRAMFS_F2FS=/home/khaon/Documents/kernels/Ramdisks/CM12_MANTA_F2FS
export INITRAMFS_EXT4=/home/khaon/Documents/kernels/Ramdisks/CM12_MANTA_EXT4
export PACKAGEDIR=/home/khaon/Documents/kernels/Packages/AOSP_Manta
export ZIP_TEMPLATE=/home/khaon/Documents/kernels/Packages/META-INF/Manta
#Enable FIPS mode
export USE_SEC_FIPS_MODE=true
export ARCH=arm
export CROSS_COMPILE=/home/khaon/Documents/toolchains/linar-4.7.a15/bin/arm-cortex_a15-linux-gnueabihf-

echo "${txtbld} Remove old Package Files ${txtrst}"
rm -rf $PACKAGEDIR/*

echo "${txtbld} Setup Package Directory ${txtrst}"
mkdir -p $PACKAGEDIR/system/lib/modules
mkdir -p $PACKAGEDIR/system/etc/init.d

echo "${txtbld} Remove old zImage ${txtrst}"
make mrproper
rm $PACKAGEDIR/zImage
rm arch/arm/boot/zImage

echo "${bldblu} Make the kernel ${txtrst}"
make khaon_manta_defconfig

make -j12

echo "${txtbld} Copy modules to Package ${txtrst} "
cp -a $(find . -name *.ko -print |grep -v initramfs) $PACKAGEDIR/system/lib/modules

echo "${txtbld} Copy scripts to init.d ${txtrst}"
cp $KERNELDIR/frandom/00frandom $PACKAGEDIR/system/etc/init.d

if [ -e $KERNELDIR/arch/arm/boot/zImage ]; then
	echo " ${bldgrn} Kernel built !! ${txtrst}"
	echo "Copy zImage to Package"
	cp arch/arm/boot/zImage $PACKAGEDIR/zImage

	echo "Make f2fs boot.img"
	./mkbootfs $INITRAMFS_F2FS | gzip > $PACKAGEDIR/ramdisk.gz
	./mkbootimg --cmdline 'console = null androidboot.selinux=permissive' --kernel $PACKAGEDIR/zImage --ramdisk $PACKAGEDIR/ramdisk.gz --base 0x10000000 --pagesize 2048 --ramdiskaddr 0x11000000 --output $PACKAGEDIR/boot.img
	export curdate=`date "+%m-%d-%Y"`
	cd $PACKAGEDIR
	cp -R $ZIP_TEMPLATE/* .
	rm ramdisk.gz
	rm ../khaon_kernel_manta_linux*.zip
	zip -r ../khaon_kernel_manta_linux_mainline-"${curdate}"_F2FS_CM12.zip . -x zImage
  rm boot.img
	cd $KERNELDIR
	echo ""

	echo "Make ext4 boot.img"
	./mkbootfs $INITRAMFS_EXT4 | gzip > $PACKAGEDIR/ramdisk.gz
	./mkbootimg --cmdline 'console = null androidboot.selinux=permissive' --kernel $PACKAGEDIR/zImage --ramdisk $PACKAGEDIR/ramdisk.gz --base 0x10000000 --pagesize 2048 --ramdiskaddr 0x11000000 --output $PACKAGEDIR/boot.img
	cd $PACKAGEDIR
	rm ramdisk.gz
  rm zImage
  zip -r ../khaon_kernel_manta_linux_mainline-"${curdate}"_EXT4_CM12.zip . -x zImage
	cd $KERNELDIR
else
	echo "KERNEL DID NOT BUILD! no zImage exist"
fi;

