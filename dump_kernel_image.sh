
BLOCK=/dev/block/platform/dw_mmc.0/by-name/boot
OUT=/home/khaon/kernels/kernel_samsung_manta/zImage


# dump boot to /tmp
dump_boot() {
  adb shell dd if=$BLOCK of=/tmp/boot.img;
}
#slice the boot img
slice_boot() {
  adb push unpackbootimg /tmp/unpackbootimg
  adb shell /tmp/unpackbootimg -i /tmp/anykernel/boot.img -o /tmp;
}
#pull the zImage 
pull_zImage() {
  adb pull /tmp/zImage $OUT;
}



dump_boot;
slice_boot:
pull_zImage;
