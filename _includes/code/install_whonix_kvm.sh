#! /bin/bash

set -eu

################################################################################
# install whonix on kvm in arch linux.
################################################################################
CURDIR=${PWD}
KVMDIR=${HOME}/.kvm
WHONIX_VERSION=13.0.0.1.1
PATRICK_FINGERPRINT="916B 8D99 C38E AF5E 8ADC  7A2A 8D66 066A 2EEA CCDA"

mkdir -p ${KVMDIR}
cd ${KVMDIR}

################################################################################
# download, verify, and extract whonix files. 
################################################################################

# download the compressed files via tor. 
torify wget https://www.whonix.org/download/${WHONIX_VERSION}/Whonix-Gateway-${WHONIX_VERSION}.libvirt.xz
torify wget https://www.whonix.org/download/${WHONIX_VERSION}/Whonix-Workstation-${WHONIX_VERSION}.libvirt.xz
torify wget https://www.whonix.org/download/${WHONIX_VERSION}/Whonix-Gateway-${WHONIX_VERSION}.libvirt.xz.asc
torify wget https://www.whonix.org/download/${WHONIX_VERSION}/Whonix-Workstation-${WHONIX_VERSION}.libvirt.xz.asc
torify wget https://www.whonix.org/patrick.asc

# download patrick's gpg key and check the fingerprint.
FINGERPRINT=$(gpg --with-fingerprint patrick.asc | \
   sed -n "s/^\s*\([A-Z0-9\ ]*\)$/\1/p")

if [ "${FINGERPRINT}" = "${PATRICK_FINGERPRINT}" ]; then
   gpg --import patrick.asc
else
   echo "downloaded fingerprint does not match hard-coded one:"
   echo "hard-coded: ${PATRICK_FINGERPRINT}"
   echo "downloaded: ${FINGERPRINT}"
   echo "exiting."
   exit 1
fi

# verify the images.
gpg --verify Whonix-Gateway-${WHONIX_VERSION}.libvirt.xz.asc Whonix-Gateway-${WHONIX_VERSION}.libvirt.xz
gpg --verify Whonix-Workstation-${WHONIX_VERSION}.libvirt.xz.asc Whonix-Workstation-${WHONIX_VERSION}.libvirt.xz

# extract.
tar xf Whonix-Gateway-${WHONIX_VERSION}.libvirt.xz
tar xf Whonix-Workstation-${WHONIX_VERSION}.libvirt.xz

# rename vm images. 
mv Whonix-Gateway-${WHONIX_VERSION}.qcow2 Whonix-Gateway.qcow2
mv Whonix-Workstation-${WHONIX_VERSION}.qcow2 Whonix-Workstation.qcow2

# change vm image location in xml rules. 
sed -i "s|\/var\/lib\/libvirt\/images|${PWD}|g" Whonix-Gateway-${WHONIX_VERSION}.xml
sed -i "s|\/var\/lib\/libvirt\/images|${PWD}|g" Whonix-Workstation-${WHONIX_VERSION}.xml 

################################################################################
# set up virtual machines. 
################################################################################

# check that network is up. 
IS_ACTIVE=$(virsh -c qemu:///system net-info default | grep "Active" | \
   cut -d ":" -f2 | sed -e "s/\s//g")
IS_AUTOSTART=$(virsh -c qemu:///system net-info default | grep "Autostart" | \
   cut -d ":" -f2 | sed -e "s/\s//g")

[ "${IS_ACTIVE}" = "no" ] && virsh -c qemu:///system net-start default
[ "${IS_AUTOSTART}" = "no" ] && virsh -c qemu:///system net-autostart default

# define vms and network rules. 
virsh -c qemu:///system define Whonix-Gateway-${WHONIX_VERSION}.xml
virsh -c qemu:///system net-define Whonix_network-${WHONIX_VERSION}.xml
virsh -c qemu:///system net-autostart Whonix
virsh -c qemu:///system net-start Whonix
virsh -c qemu:///system define Whonix-Workstation-${WHONIX_VERSION}.xml

################################################################################
# cleanup and exit. 
################################################################################

rm Whonix-Gateway-${WHONIX_VERSION}.libvirt.xz
rm Whonix-Workstation-${WHONIX_VERSION}.libvirt.xz
rm Whonix-Gateway-${WHONIX_VERSION}.libvirt.xz.asc
rm Whonix-Workstation-${WHONIX_VERSION}.libvirt.xz.asc

cd ${CURDIR}
