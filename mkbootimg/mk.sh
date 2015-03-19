#!/bin/bash

#Path to buildroot
DIR="/opt/android/cm11"

CMDLINE='androidboot.hardware=d605 user_debug=31 msm_rtb msm_rtb.filter=0x3F vmalloc=271M ehci-hcd.park=3 maxcpus=2'

read NOW << EOF
`pwd`
EOF

if [ "$ANDROID_BUILD_TOP" = "" ]; then
    cd $DIR
    source build/envsetup*
    breakfast d605
    cd $NOW
fi

if [ -f boot.img ]; then
    rm boot.img
fi

mkbootfs -f META/boot_filesystem_config.txt RAMDISK > ramdisk
minigzip ramdisk > ramdisk.gz
mkbootimg --kernel kernel --cmdline "`echo $CMDLINE`" --base 0x80200000 --pagesize 2048 --ramdisk_offset 0x02000000 --ramdisk ramdisk.gz --output boota.img
loki_tool patch boot ./aboot.img ./boota.img boot.img
rm boota.img
rm ramdisk.gz
