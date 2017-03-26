#! /bin/bash
set -eu

################################################################################
# install whonix on kvm in arch linux.
################################################################################

################################################################################
# define global variables.
################################################################################

CURDIR=${PWD}
LIBVIRT_DIR=${HOME}/.local/libvirt/images
WHONIX_VERSION=13.0.0.1.4
DOMAIN_NAME="whonix.org"
IP_ADDR=`tor-resolve ${DOMAIN_NAME}`
PATRICK_FINGERPRINT="916B 8D99 C38E AF5E 8ADC  7A2A 8D66 066A 2EEA CCDA"


################################################################################
# (optional) define local storage pool at .local/libvirt/images.
################################################################################

mkdir -p ${LIBVIRT_DIR}
cd ${LIBVIRT_DIR}


################################################################################
# download, verify, and extract whonix files.
################################################################################

# download the compressed files via tor.
GATEWAY=Whonix-Gateway-${WHONIX_VERSION}.libvirt.xz
WORKSTATION=Whonix-Workstation-${WHONIX_VERSION}.libvirt.xz
GATEWAY_URL=https://download.${DOMAIN_NAME}/linux/${WHONIX_VERSION}/${GATEWAY}
WORKSTATION_URL=https://download.${DOMAIN_NAME}/linux/${WHONIX_VERSION}/${WORKSTATION}

torify wget -N ${GATEWAY_URL}
torify wget -N ${GATEWAY_URL}.asc
torify wget -N ${WORKSTATION_URL}
torify wget -N ${WORKSTATION_URL}.asc

# import patrick's gpg key if it has not been imported already.
if ! gpg --fingerprint "${PATRICK_FINGERPRINT}" >/dev/null; then
  gpg --keyserver pgp.mit.edu --recv 0x8D66066A2EEACCDA
fi

# verify the images.
gpg --verify Whonix-Gateway-${WHONIX_VERSION}.libvirt.xz.asc \
  Whonix-Gateway-${WHONIX_VERSION}.libvirt.xz
gpg --verify Whonix-Workstation-${WHONIX_VERSION}.libvirt.xz.asc \
  Whonix-Workstation-${WHONIX_VERSION}.libvirt.xz

# extract.
echo "extracting whonix gateway."
tar xf Whonix-Gateway-${WHONIX_VERSION}.libvirt.xz
echo "extracting whonix workstation."
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

# comment out acceleration lines in the xml files. they are not supported.
sed -i "s/<acceleration accel3d/<\!--<acceleration accel3d/" \
  Whonix-Workstation-${WHONIX_VERSION}.xml
sed -i "s/ accel2d='yes'\/>/ accel2d='yes'\/>-->/" \
  Whonix-Workstation-${WHONIX_VERSION}.xml
sed -i "s/<acceleration accel3d/<\!--<acceleration accel3d/" \
  Whonix-Gateway-${WHONIX_VERSION}.xml
sed -i "s/ accel2d='yes'\/>/ accel2d='yes'\/>-->/" \
  Whonix-Gateway-${WHONIX_VERSION}.xml

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
