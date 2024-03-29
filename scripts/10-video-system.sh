#!/bin/bash

if lspci | grep -i VGA | grep -q Intel; then
    sudo emerge sys-firmware/intel-microcode --autounmask{,-write,-continue}
    sudo emerge x11-drivers/xf86-video-intel --autounmask{,-write,-continue}
fi

if lspci -nnkv | sed -n '/Network/,/^$/p' | grep -q iwlwifi; then
    sudo modprobe iwlwifi
fi

if lspci | grep -q nvidia; then
    read -p "Nvidia or Nouveau: " input

    sudo emerge sys-firmware/nvidia-firmware --autounmask{,-write,-continue}

    if [ "$input" = "nvidia" ]; then
        sudo emerge x11-drivers/nvidia-drivers --autounmask{,-write,-continue}
        sudo modprobe nvidia
    elif [ "$input" = "nouveau" ]; then
        sudo emerge x11-drivers/xf86-video-nouveau --autounmask{,-write,-continue}
        sudo modprobe nouveau
    else
        echo "Please enter a valid option"
    fi
fi

if lspci | grep -i VGA | grep -q AMD; then
    sudo emerge x11-drivers/xf86-video-amdgpu --autounmask{,-write,-continue}
    modprobe amdgpu
fi

if lspci -nnkv | sed -n '/Network/,/^$/p' | grep -qE "Atheros|Qualcomm"; then
    modprobe ath9k
fi

#utility
sudo emerge sys-fs/ntfs3g --autounmask{,-write,-continue}
sudo emerge sys-apps/usbutils --autounmask{,-write,-continue}
sudo emerge app-portage/eix --autounmask{,-write,-continue}
