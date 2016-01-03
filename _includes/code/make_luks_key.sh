#! /bin/bash

################################################################################
# (optional) create a binary luks key to store in the initial ramdisk. 
################################################################################

# generate keyfile and prevent non-root from reading it. 
dd bs=512 count=4 if=/dev/random of=/etc/crypto_keyfile.bin
chmod 600 /etc/crypto_keyfile.bin
cryptsetup luksAddKey /dev/sdX1 /etc/crypto_keyfile.bin

# add key to /etc/mkinitcpio.conf
sed -i "s/FILES=\".*\"/FILES=\"\/etc\/crypto_keyfile.bin\"/g" /etc/mkinitcpio.conf

# rebuild the kernel
mkinitcpio -p linux

# add key to grub config file
CRYPTO_KEY="cryptkey=rootfs:/etc/crypto_keyfile.bin"
CUR_GRUB_CMDLINE_LINUX=$(grep "GRUB_CMDLINE_LINUX=" grub)
NEW_GRUB_CMDLINE_LINUX=$(echo $CUR_GRUB_CMDLINE_LINUX | cut -d \" -f2)
NEW_GRUB_CMDLINE_LINUX="GRUB_CMDLINE_LINUX=$NEW_GRUB_CMDLINE_LINUX $CRYPTO_KEY"
sed -i "s/$CUR_GRUB_CMDLINE_LINUX/$NEW_GRUB_CMDLINE_LINUX/g" /etc/default/grub
