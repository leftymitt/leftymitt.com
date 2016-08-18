#! /bin/bash

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

# set locale
locale-gen 
sed -i 's/#LANG=en_US.UTF-8/LANG=en_US.UTF-8/g' /etc/locale.conf

# set time
tzselect
ln -s /usr/share/zoneinfo/Zone/SubZone /etc/localtime
hwclock --systohc --utc

# set hostname and append hostname to /etc/hosts
YOUR_HOSTNAME=hostname
echo "$YOUR_HOSTNAME" > /etc/hostname
sed -i "s/localhost/localhost\t$YOUR_HOSTNAME" /etc/hosts 

# install wireless tools
pacman -S iw wpa_supplicant dialog

################################################################################
# add encrypt and lvm2 modules to /etc/mkinitcpio.conf.
################################################################################
OLD_HOOKS="base udev autodetect modconf block filesystems keyboard fsck"
NEW_HOOKS="base udev autodetect modconf block encrypt lvm2 filesystems keyboard fsck"
sed -i "s/$OLD_HOOKS/$NEW_HOOKS/g" /etc/mkinitcpio.conf

# build initial ramdisk
mkinitcpio -p linux

################################################################################
# install grub (assuing bios/mbr) and add encryption support.
################################################################################
pacman -S grub os-prober
grub-install --recheck /dev/${DEVICE}

FOR_SSD="cryptdevice=/dev/${DEVICE}1:lvm:allow-discards"
LVM_ROOT="root=/dev/mapper/vg-root"
GRUB_CMDLINE_LINUX="GRUB_CMDLINE_LINUX=$FOR_SSD $LVM_ROOT"
GRUB_ENABLE_CRYPTODISK="GRUB_ENABLE_CRYPTODISK=y"

echo "$GRUB_ENABLE_CRYPTODISK" >> /etc/default/grub
echo "$GRUB_CMDLINE_LINUX" >> /etc/default/grub

grub-mkconfig -o /boot/grub/grub.cfg


################################################################################
# set root password, unmount, and reboot.
################################################################################
passwd # set root password
umount -R /mnt # unmount
reboot
