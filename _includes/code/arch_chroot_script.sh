#! /bin/bash
set -eu

REGION=UTC
CITY=


################################################################################
# prompt for info.
################################################################################

DISKS=($(lsblk | grep disk | cut -d" " -f1 | tr "\n" " "))
echo "install on which disk?"
select DEVICE in "${DISKS[@]}"; do
  echo "${DEVICE} selected"
  break
done

read -r -p "use device ${DEVICE}? (y/N): " REPLY
if [[ ! ${REPLY} =~ ^([Yy]$|[Yy]es) ]]; then
  echo "stopping script..."
  exit 1
fi

read -r -p 'enter a new hostname: ' HOSTNAME
read -r -p 'enter a new username: ' USER


################################################################################
# configure base system.
################################################################################

# set time
# rm /etc/localtime
if [ ${REGION} == "UTC" ]; then
  ln -sfn /usr/share/zoneinfo/${REGION} /etc/localtime
else
  ln -sfn /usr/share/zoneinfo/${REGION}/${CITY} /etc/localtime
fi
hwclock --systohc --utc

# set locale
LOCALE=$(locale | grep ^LANG | cut -d= -f2 | cut -d\. -f1)
sed -i "/^#${LOCALE}.UTF/s/^#//" /etc/locale.gen
locale-gen
echo LANG=${LOCALE} > /etc/locale.conf

# set hostname and append hostname to /etc/hosts
echo ${HOSTNAME} > /etc/hostname
sed -i "/::1/a 127.0.1.1\t${HOSTNAME}.localdomain\t${HOSTNAME}" /etc/hosts

# install wireless tools
pacman -S iw wpa_supplicant dialog


################################################################################
# add encrypt and lvm2 modules to /etc/mkinitcpio.conf.
################################################################################

OLD_HOOKS="base udev autodetect modconf block filesystems keyboard fsck"
NEW_HOOKS="base udev autodetect modconf block encrypt lvm2 filesystems keyboard fsck"
sed -i "s/${OLD_HOOKS}/${NEW_HOOKS}/g" /etc/mkinitcpio.conf

# rebuild initial ramdisk with new modules
mkinitcpio -p linux


################################################################################
# install grub (assuing bios/mbr) and add encryption support.
################################################################################

pacman -S grub os-prober
grub-install --recheck /dev/${DEVICE}

FOR_SSD="cryptdevice=/dev/${DEVICE}1:lvm:allow-discards"
LVM_ROOT="root=/dev/mapper/vg-root"
GRUB_CMDLINE_LINUX="GRUB_CMDLINE_LINUX=\"${FOR_SSD} ${LVM_ROOT}\""
GRUB_ENABLE_CRYPTODISK="GRUB_ENABLE_CRYPTODISK=y"

sed -i "s/GRUB_CMDLINE_LINUX=/${GRUB_CMDLINE_LINUX}/g" /etc/default/grub
echo "${GRUB_ENABLE_CRYPTODISK}" >> /etc/default/grub

grub-mkconfig -o /boot/grub/grub.cfg


################################################################################
# set root password, create new user, and exit.
################################################################################

echo "set a root password."
passwd

# create new user with administrator rights
echo "create a new user."
useradd -m -c ${USER} ${USER} -s /bin/bash
usermod -aG wheel,${USER} ${USER}
echo "set user password."
passwd ${USER}

visudo # uncomment wheel password privilege escalation

# (optional) run make_luks_key.sh here

exit 0
