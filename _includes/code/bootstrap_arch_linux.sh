#! /bin/bash

################################################################################
# connect to internet (automatic for wired connections).
################################################################################
wifi-menu -o wlp2s0 # wireless only

################################################################################
# detect devices and configure storage options.
################################################################################

# create partition table
parted -s /dev/sdX mklabel msdos
parted -s /dev/sdX mkpart primary 2048s 100%

# create encrypted logical volumes
cryptsetup luksFormat /dev/sdX1
cryptsetup luksOpen /dev/sdX1 lvm
pvcreate /dev/mapper/lvm
vgcreate vg /dev/mapper/lvm
lvcreate -L 4G vg -n swap
lvcreate -L 20G vg -n root
lvcreate -l +100%FREE vg -n home

# configure swap and filesystems
mkswap -L swap /dev/mapper/vg-swap
mkfs.ext4 /dev/mapper/vg-root
mkfs.ext4 /dev/mapper/vg-home

################################################################################
# mount logical volumes and bootstrap base and base-devel packages. 
################################################################################

# mount logical volumes
mount /dev/mapper/vg-root /mnt
mkdir /mnt/home
mount /dev/mapper/vg-home /mnt/home

# bootstrap
pacstrap -i /mnt base base-devel

# generate filesystem table
genfstab -U /mnt > /mnt/etc/fstab

# chroot
arch-chroot /mnt /bin/bash
