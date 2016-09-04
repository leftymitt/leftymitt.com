#! /bin/bash
set -eu

################################################################################
# install whonix on kvm in arch linux.
################################################################################

################################################################################
# define global variables.
################################################################################

CURDIR=${PWD}
KVMDIR=${HOME}/.kvm
WHONIX_VERSION=13.0.0.1.1
DOMAIN_NAME="www.whonix.org"
IP_ADDR=`tor-resolve ${DOMAIN_NAME}`
PATRICK_FINGERPRINT="916B 8D99 C38E AF5E 8ADC  7A2A 8D66 066A 2EEA CCDA"


################################################################################
# download, verify, and extract whonix files. 
################################################################################

mkdir -p ${KVMDIR}
cd ${KVMDIR}

# download the compressed files via tor. 
torify curl -O --resolve ${DOMAIN_NAME}:443:${IP_ADDR} -C - -o \
  Whonix-Gateway-${WHONIX_VERSION}.libvirt.xz \
  https://${DOMAIN_NAME}/download/${WHONIX_VERSION}/Whonix-Gateway-${WHONIX_VERSION}.libvirt.xz
torify curl -O --resolve ${DOMAIN_NAME}:443:${IP_ADDR} -C - -o \
  Whonix-Workstation-${WHONIX_VERSION}.libvirt.xz \
  https://${DOMAIN_NAME}/download/${WHONIX_VERSION}/Whonix-Workstation-${WHONIX_VERSION}.libvirt.xz
torify curl -O --resolve ${DOMAIN_NAME}:443:${IP_ADDR} -C - -o \
  Whonix-Gateway-${WHONIX_VERSION}.libvirt.xz.asc \
  https://${DOMAIN_NAME}/download/${WHONIX_VERSION}/Whonix-Gateway-${WHONIX_VERSION}.libvirt.xz.asc
torify curl -O --resolve ${DOMAIN_NAME}:443:${IP_ADDR} -C - -o \
  Whonix-Workstation-${WHONIX_VERSION}.libvirt.xz.asc \
  https://${DOMAIN_NAME}/download/${WHONIX_VERSION}/Whonix-Workstation-${WHONIX_VERSION}.libvirt.xz.asc
torify curl -O --resolve ${DOMAIN_NAME}:443:${IP_ADDR} -C - -o \
  patrick.asc \
  https://${DOMAIN_NAME}/patrick.asc

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

# disable acceleration in xml file (need to revisit this).
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
