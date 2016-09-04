#! /bin/bash
set -eu

################################################################################
# prompt for info.
################################################################################

lsblk
echo "which device? (e.g., sda, sdb, sdc, etc.)"
read DEVICE
echo "use device $DEVICE? (y/N)"
read REPLY
if [[ ! $REPLY =~ ^([Yy]$|[Yy]es) ]]; then
  echo "stopping script..."
  exit 1
fi


################################################################################
# configure base system.
################################################################################

# set locale to en_US.UTF-8
sed -i 's/#LANG=en_US.UTF-8/LANG=en_US.UTF-8/g' /etc/locale.gen
locale-gen 
echo LANG=en_US.UTF-8 > /etc/locale.conf

# set time
tzselect
ln -s /usr/share/zoneinfo/Zone/SubZone /etc/localtime
hwclock --systohc --utc

# set hostname and append hostname to /etc/hosts
HOSTNAME=hostname
echo "$HOSTNAME" > /etc/hostname
sed -i "s/localhost$/localhost\t$HOSTNAME/g" /etc/hosts 

# install wireless tools
pacman -S iw wpa_supplicant dialog


################################################################################
# add encrypt and lvm2 modules to /etc/mkinitcpio.conf.
################################################################################

OLD_HOOKS="base udev autodetect modconf block filesystems keyboard fsck"
NEW_HOOKS="base udev autodetect modconf block encrypt lvm2 filesystems keyboard fsck"
sed -i "s/$OLD_HOOKS/$NEW_HOOKS/g" /etc/mkinitcpio.conf

# rebuild initial ramdisk with new modules
mkinitcpio -p linux


################################################################################
# install grub (assuing bios/mbr) and add encryption support.
################################################################################

pacman -S grub os-prober
grub-install --recheck /dev/${DEVICE}

FOR_SSD="cryptdevice=/dev/${DEVICE}1:lvm:allow-discards"
LVM_ROOT="root=/dev/mapper/vg-root"
GRUB_CMDLINE_LINUX="GRUB_CMDLINE_LINUX=\"$FOR_SSD $LVM_ROOT\""
GRUB_ENABLE_CRYPTODISK="GRUB_ENABLE_CRYPTODISK=y"

sed -i "s/GRUB_CMDLINE_LINUX=/$GRUB_CMDLINE_LINUX/g" grub
echo "$GRUB_ENABLE_CRYPTODISK" >> /etc/default/grub

grub-mkconfig -o /boot/grub/grub.cfg


################################################################################
# set root password and exit
################################################################################

passwd # set root password

# (optional) run make_luks_key.sh here

exit
