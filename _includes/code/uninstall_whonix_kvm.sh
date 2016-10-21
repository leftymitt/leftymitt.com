#! /bin/bash
set -eu

################################################################################
# uninstall kvm images. assumes kvm images are in ~/.kvm directory.
################################################################################

CURDIR=${PWD}
LIBVIRT_DIR=${HOME}/.local/libvirt/images
WHONIX_VERSION=13.0.0.1.1

cd ${LIBVIRT_DIR}

# make sure kvm is shut down.
if ! [ "$(virsh list --all | grep running | grep Gateway)" = "" ]; then
  virsh -c qemu:///system destroy Whonix-Gateway
fi
if ! [ "$(virsh list --all | grep running | grep Workstation)" = "" ]; then
  virsh -c qemu:///system destroy Whonix-Workstation
fi

# remove vm settings.
virsh -c qemu:///system undefine Whonix-Gateway
virsh -c qemu:///system undefine Whonix-Workstation

# remove network rules.
virsh -c qemu:///system net-destroy Whonix
virsh -c qemu:///system net-undefine Whonix

# delete vm images. 
rm -f Whonix-Gateway.qcow2
rm -f Whonix-Workstation.qcow2
rm -f Whonix_network-${WHONIX_VERSION}.xml
rm -f Whonix-Gateway-${WHONIX_VERSION}.xml
rm -f Whonix-Workstation-${WHONIX_VERSION}.xml

cd ${CURDIR}
