#! /bin/bash

################################################################################
# uninstall kvm images. assumes kvm images are in ~/.kvm directory.
################################################################################

CURDIR=${PWD}
KVMDIR=${HOME}/.kvm

cd ${KVMDIR}

# make sure kvm is shut down.
virsh -c qemu:///system destroy Whonix-Gateway
virsh -c qemu:///system destroy Whonix-Workstation

# remove vm settings.
virsh -c qemu:///system undefine Whonix-Gateway
virsh -c qemu:///system undefine Whonix-Workstation

# remove network rules.
virsh -c qemu:///system net-destroy Whonix
virsh -c qemu:///system net-undefine Whonix

# delete vm images. 
rm Whonix-Gateway.qcow2
rm Whonix-Workstation.qcow2

cd ${CURDIR}
