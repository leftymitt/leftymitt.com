#! /bin/bash

################################################################################
# install dependencies for whonix and kvm.
################################################################################

sudo pacman -S \
  libvirt qemu virt-manager dnsmasq ebtables bridge-utils tor torsocks

sudo systemctl enable tor.service
sudo systemctl enable libvirtd.service
sudo usermod -aG kvm,libvirt $(whoami)

# set qemu user to `whoami` instead of nobody.
sudo sed -i "s/#user = \"root\"/user = \"`whoami`\"/g" /etc/libvirt/qemu.conf

# reboot here.
echo "reboot your computer now."
