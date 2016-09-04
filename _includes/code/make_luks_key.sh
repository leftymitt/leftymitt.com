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
# (optional) create a binary luks key to store in the initial ramdisk. 
################################################################################

# generate keyfile and prevent non-root from reading it. 
dd bs=512 count=4 if=/dev/urandom of=/etc/crypto_keyfile.bin
chmod 400 /etc/crypto_keyfile.bin
cryptsetup luksAddKey /dev/${DEVICE}1 /etc/crypto_keyfile.bin

# add key to /etc/mkinitcpio.conf
sed -i "s/FILES=\".*\"/FILES=\"\/etc\/crypto_keyfile.bin\"/g" /etc/mkinitcpio.conf

# rebuild the kernel
mkinitcpio -p linux

# add key to grub config file
CRYPTO_KEY="cryptkey=rootfs:/etc/crypto_keyfile.bin"
CUR_GRUB_CMDLINE_LINUX=$(grep "^GRUB_CMDLINE_LINUX=" /etc/default/grub)
NEW_GRUB_CMDLINE_LINUX=$(echo $CUR_GRUB_CMDLINE_LINUX | cut -d \" -f2)
NEW_GRUB_CMDLINE_LINUX="GRUB_CMDLINE_LINUX=$NEW_GRUB_CMDLINE_LINUX $CRYPTO_KEY"
sed -i "s/$CUR_GRUB_CMDLINE_LINUX/$NEW_GRUB_CMDLINE_LINUX/g" /etc/default/grub
