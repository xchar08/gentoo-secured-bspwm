#!/bin/bash

if lspci | grep -i VGA | grep -c Intel > 0
then
emerge --ask sys-firmware/intel-microcode --autounmask{,-write,-continue}
emerge --ask x11-drivers/xf86-video-intel --autounmask{,-write,-continue}
fi

if lspci -nnkv | sed -n '/Network/,/^$/p' | grep -c iwlwifi > 0
then
modprobe iwlwifi
fi

if lspci | grep -c nvidia > 0
then
emerge --ask x11-drivers/nvidia-drivers --autounmask{,-write,-continue}
emerge --ask sys-firmware/nvidia-firmware --autounmask{,-write,-continue}
modprobe nvidia
fi

#utility
emerge --ask x11-misc/wmname --autounmask{,-write,-continue}
emerge --ask sys-fs/ntfs3g --autounmask{,-write,-continue}
emerge --ask sys-apps/usbutils --autounmask{,-write,-continue}
emerge --ask app-portage/eix --autounmask{,-write,-continue}

#fonts
emerge --ask media-fonts/source-pro --autounmask{,-write,-continue}
emerge --ask media-fonts/noto --autounmask{,-write,-continue}
emerge --ask media-fonts/noto-emoji --autounmask{,-write,-continue}

#terminal
echo -n "Select terminal (alacritty, kitty, xterm): "
read term
case "$term" in
"alacritty") emerge --ask x11-terms/alacritty --autounmask{,-write,-continue} ;;
"kitty") emerge --ask x11-terms/kitty --autounmask{,-write,-continue} ;;
"xterm") emerge --ask x11-terms/xterm --autounmask{,-write,-continue} ;;
esac

#!/bin/bash

read -p "Do you want to set up regular zram or encrypted zram? (r/e)" choice

case "$choice" in 
  r|R )
    # Set up regular zram
    modprobe zram
    echo $((6144*1024*1024)) > /sys/block/zram0/disksize
    mkswap /dev/zram0
    swapon /dev/zram0 -p 10
    touch /etc/local.d/zram.start
    touch /etc/local.d/zram.stop
    chmod +x /etc/local.d/zram.start
    chmod +x /etc/local.d/zram.stop
    rc-update add local default 
    ;;
  e|E )
    # Set up encrypted zram
    modprobe zram
    echo $((6144*1024*1024)) > /sys/block/zram0/disksize
    echo 1 > /sys/block/zram0/reset
    cryptsetup -c aes-xts-plain64 -s 256 luksFormat /dev/zram0
    cryptsetup open /dev/zram0 zram0_crypt
    mkswap /dev/mapper/zram0_crypt
    swapon /dev/mapper/zram0_crypt -p 10
    cat << EOF > /etc/local.d/zram.start
#!/bin/sh
modprobe zram
echo $((6144*1024*1024)) > /sys/block/zram0/disksize
echo 1 > /sys/block/zram0/reset
cryptsetup open /dev/zram0 zram0_crypt
mkswap /dev/mapper/zram0_crypt
swapon /dev/mapper/zram0_crypt -p 10
EOF
    cat << EOF > /etc/local.d/zram.stop
#!/bin/sh
swapoff /dev/mapper/zram0_crypt
cryptsetup close zram0_crypt
echo 1 > /sys/block/zram0/reset
echo 0 > /sys/block/zram0/disksize
modprobe -r zram
EOF
    chmod +x /etc/local.d/zram.start
    chmod +x /etc/local.d/zram.stop
    rc-update add local default 
    ;;
  * )
    echo "Invalid choice. Please choose 'r' or 'e'."
    ;;
esac

