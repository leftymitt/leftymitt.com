#! /bin/bash
set -eu

################################################################################
# prompt for info.
################################################################################

DISKS=($(lsblk | grep disk | cut -d" " -f1 | tr "\n" " "))
echo "install on which disk?"
select DEVICE in "${DISKS[@]}"; do
  echo "${DEVICE} selected"
  break
done

read -r -p "use device ${DEVICE}? (y/N) " REPLY
if [[ ! ${REPLY} =~ ^([Yy]$|[Yy]es) ]]; then
  echo "stopping script..."
  exit 1
fi


################################################################################
# connect to internet (usually automatic for wired connections).
################################################################################

# check if connection active
wget -q --tries=10 --timeout=20 --spider https://google.com
if ! [[ $? -eq 0 ]]; then
  # for wireless connections (connects to first interface available)
  if iw dev | grep Interface > /dev/null; then
    wifi-menu -o $(iw dev | grep -n 1 "Interface" | \
                   sed -n "s/^\s*Interface \(.*\)$/\1/p")
  else
    echo "no wireless interface available. check your wired connection."
  fi
fi


# for non-broadcasting wireless networks, wifi-menu will fail. manually define
# the netork via netctl. see examples available in /etc/netcl. once definined
# network <my_network> is in /etc/netctl, run:
#
#   netctl start <my_network>
#
# to automatically connect from now on, also run:
#
#   netctl enable <my_network>
#   systemctl enable netctl@<my_network>.service


################################################################################
# detect devices and configure storage options.
################################################################################

echo "start paritioning device: ${DEVICE}."

# create partition table
parted -s /dev/${DEVICE} mklabel msdos
parted -s /dev/${DEVICE} mkpart primary 2048s 100%

# create encrypted logical volumes
echo "initialize luks partition."
cryptsetup luksFormat /dev/${DEVICE}1
echo "set password for opening luks volume."
cryptsetup luksOpen /dev/${DEVICE}1 lvm
echo "enter newly set password to mount luks volume."
pvcreate /dev/mapper/lvm
vgcreate vg /dev/mapper/lvm
lvcreate -L 4G vg -n swap
lvcreate -L 20G vg -n root
lvcreate -l +100%FREE vg -n home

# configure swap and filesystems
mkswap -L swap /dev/mapper/vg-swap
swapon /dev/mapper/vg-swap
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
genfstab -U /mnt >> /mnt/etc/fstab

# if swap partition wasn't added to the fstab, add it manually
if test "$(grep '^UUID.*swap' /etc/fstab)"; then
  echo -e "# /dev/mapper/vg-swap LABEL=swap" >> /mnt/etc/fstab
  echo -e "UUID=$(lsblk -no UUID /dev/mapper/vg-swap)\tnone      \tswap      \tdefaults  \t0 0" >> /mnt/etc/fstab
  echo -e "" >> /mnt/etc/fstab
fi

# execute chroot script to install base system
if [ -f arch_chroot_script.sh ]; then
  cp -f arch_chroot_script.sh /mnt
  arch-chroot /mnt ./arch_chroot_script.sh
  rm -f /mnt/arch_chroot_script.sh
fi

# execute chroot script to build luks key into initcpio
if [ -f make_luks_key.sh ]; then
  cp -f make_luks_key.sh /mnt
  arch-chroot /mnt ./make_luks_key.sh
  rm -f /mnt/make_luks_key.sh
fi


################################################################################
# return from chroot, clean up, and reboot.
################################################################################

umount -R /mnt

# remove the live image when rebooting
reboot
