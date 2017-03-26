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

torify curl ${GATEWAY_URL} --resolve ${DOMAIN_NAME}:443:${IP_ADDR} \
  -C - -o ${GATEWAY}
torify curl ${GATEWAY_URL}.asc --resolve ${DOMAIN_NAME}:443:${IP_ADDR} \
  -C - -o ${GATEWAY}
torify curl ${WORKSTATION_URL} --resolve ${DOMAIN_NAME}:443:${IP_ADDR} \
  -C - -o ${WORKSTATION}.asc
torify curl ${WORKSTATION_URL}.asc --resolve ${DOMAIN_NAME}:443:${IP_ADDR} \
  -C - -o ${WORKSTATION}.asc

# check if patrick's gpg key has already been imported. If not, download it.
KEY=patrick.asc
KEY_URL=https://${DOMAIN_NAME}/${KEY}
if ! gpg --fingerprint "${PATRICK_FINGERPRINT}"; then
  torify curl ${KEY_URL} --resolve ${DOMAIN_NAME}:443:${IP_ADDR} \
    -C - -o patrick.asc
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
