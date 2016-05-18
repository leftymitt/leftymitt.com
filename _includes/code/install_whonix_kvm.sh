#! /bin/bash

################################################################################
# install whonix on kvm in arch linux.
################################################################################
CURDIR=${PWD}
KVMDIR=${HOME}/.local/share/kvm
WHONIX_VERSION=12.0.0.3.2

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

# verify the images.
gpg --with-fingerprint patrick.asc # check the fingerprint
gpg --import patrick.asc
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
virsh -c qemu:///system net-autostart default
virsh -c qemu:///system net-start default

# define vms and network rules. 
virsh -c qemu:///system define Whonix-Gateway*.xml
virsh -c qemu:///system net-define Whonix_network*.xml
virsh -c qemu:///system net-autostart Whonix
virsh -c qemu:///system net-start Whonix
virsh -c qemu:///system define Whonix-Workstation*.xml

################################################################################
# cleanup and exit. 
################################################################################
rm Whonix-Gateway-${WHONIX_VERSION}.libvirt.xz
rm Whonix-Workstation-${WHONIX_VERSION}.libvirt.xz
rm Whonix-Gateway-${WHONIX_VERSION}.libvirt.xz.asc
rm Whonix-Workstation-${WHONIX_VERSION}.libvirt.xz.asc

cd ${CURDIR}
