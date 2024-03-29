#!/bin/bash

#installation
sudo emerge sys-firmware/sof-firmware --autounmask{,-write,-continue}
sudo emerge media-sound/pulseaudio --autounmask{,-write,-continue}
sudo emerge media-libs/libpulse --autounmask{,-write,-continue}
sudo emerge media-video/wireplumber --autounmask{,-write,-continue}

#configuration
sudo mkdir -p /etc/pipewire
sudo cp /usr/share/pipewire/pipewire.conf /etc/pipewire/pipewire.conf
mkdir -p ~/.config/pipewire
cp /usr/share/pipewire/pipewire.conf ~/.config/pipewire/pipewire.conf

echo "Enter your username:"
read -r us

#groupadd
sudo gpasswd -a "$us" audio
sudo gpasswd -a "$us" video

#profiles
echo '
#!/bin/bash
# Ensure XDG_RUNTIME_DIR is set
if test -z "$XDG_RUNTIME_DIR"; then
    export XDG_RUNTIME_DIR=$(mktemp -d /tmp/$(id -u)-runtime-dir.XXX)
fi
' > ~/.bash_profile

source ~/.bash_profile

echo '
#!/bin/zsh
# Ensure XDG_RUNTIME_DIR is set
if test -z "$XDG_RUNTIME_DIR"; then
    export XDG_RUNTIME_DIR=$(mktemp -d /tmp/$(id -u)-runtime-dir.XXX)
fi

sudo cp -r /usr/share/pipewire/ /etc/ 
' > ~/.zprofile

source ~/.zprofile

sudo cp -r /usr/share/pipewire/ /etc/ 
sudo sed -i 's/# *\(.*"tcp:4713"\)\s*# IPv4 and IPv6 on all addresses/\1 # IPv4 and IPv6 on all addresses/' /etc/pipewire/pipewire-pulse.conf

