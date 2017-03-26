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

read -r -p "use device ${DEVICE}? (y/N): " REPLY
if [[ ! ${REPLY} =~ ^([Yy]$|[Yy]es) ]]; then
  echo "stopping script..."
  exit 1
fi


################################################################################
# (optional) create a binary luks key to store in the initial ramdisk.
################################################################################

# generate keyfile and prevent non-root from reading it.
CRYPTOKEY="/etc/crypto_keyfile.bin"
dd bs=512 count=4 if=/dev/urandom of=${CRYPTOKEY}
chmod 400 ${CRYPTOKEY}
cryptsetup luksAddKey /dev/${DEVICE}1 ${CRYPTOKEY}

# add key to /etc/mkinitcpio.conf
OLD_MKINITCPIO_FILES=$(sed -n "s/^FILES=\"\(.*\)\"/\1/p" /etc/mkinitcpio.conf)
NEW_MKINITCPIO_FILES=$(echo ${OLD_MKINITCPIO_FILES} ${CRYPTOKEY})
sed -i "s|^FILES=\"${OLD_MKINITCPIO_FILES}\"|FILES=\"${NEW_MKINITCPIO_FILES}\"|g" /etc/mkinitcpio.conf

# rebuild the kernel
mkinitcpio -p linux

# add key to grub config file
CRYPTO_KEY="cryptkey=rootfs:${CRYPTOKEY}"
OLD_GRUB_CMDLINE_LINUX=$(sed -n "s/^GRUB_CMDLINE_LINUX=\"\(.*\)\"/\1/p" /etc/default/grub)
NEW_GRUB_CMDLINE_LINUX="${NEW_GRUB_CMDLINE_LINUX} ${CRYPTO_KEY}"
sed -i "s|${OLD_GRUB_CMDLINE_LINUX}|${NEW_GRUB_CMDLINE_LINUX}|g" /etc/default/grub

# rebuild grub
grub-mkconfig -o /boot/grub/grub.cfg
