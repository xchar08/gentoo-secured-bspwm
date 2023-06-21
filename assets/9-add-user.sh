#!/bin/bash

#create user and configure sudo

emerge app-admin/sudo --autounmask{,-write,-continue}

echo "Please enter the username you would like to create in Gentoo:"
read -r us
usermod -aG wheel,video,audio,user,portage "$us"
echo "$us" | sudo tee /etc/hostname
echo "%wheel ALL=(ALL:ALL) ALL" | sudo tee -a /etc/sudoers
echo -e "Defaults rootpw\nDefaults !tty_tickets" | sudo tee -a /etc/sudoers
mkdir -p /root/Desktop