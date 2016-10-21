#! /bin/bash
set -eu

################################################################################
# install dependencies for whonix and kvm.
################################################################################

sudo pacman -S \
  libvirt qemu virt-manager dnsmasq ebtables bridge-utils tor torsocks

sudo systemctl enable tor.service
sudo systemctl enable libvirtd.service
sudo usermod -aG kvm,libvirt $(whoami)

# enable dynamic file permissions. 
sudo sed -i "s/#dynamic_ownership = 1/dynamic_ownership = 1/" /etc/libvirt/qemu.conf

# reboot here.
echo "reboot your computer now."
