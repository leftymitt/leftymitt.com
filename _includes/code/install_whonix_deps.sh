#! /bin/bash

################################################################################
# install dependencies for whonix and kvm.
################################################################################

sudo pacman -S libvirt qemu virt-manager dnsmasq ebtables bridge-utils

sudo systemctl enable libvirtd.service
sudo usermod -aG kvm,libvirt $(whoami)

# reboot here.
echo "reboot your computer now."
