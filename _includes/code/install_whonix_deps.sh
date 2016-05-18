#! /bin/bash

################################################################################
# install dependencies for whonix and kvm.
################################################################################
sudo pacman -S libvirt qemu virt-manager dnsmasq ebtables

sudo systemctl enable libvirtd.service
sudo usermod -aG kvm $(whoami)

# reboot here.
echo "reboot your computer now."

