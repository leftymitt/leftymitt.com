---
title: install arch linux with an encrypted boot partition.
categories: resources
layout: post
icon: arch-linux-logo.svg
added_date: "2016-01-03"
published_date: "2016-01-03"
code: 
 - script: bootstrap_arch_linux.sh
   language: bash
 - script: arch_chroot_script.sh
   language: bash
 - script: make_luks_key.sh
   language: bash
---

The [Arch Wiki](https://wiki.archlinux.org/) will tell you how to install Arch with a separate, unencrypted boot partition, but it won't help if you want to encrypt your boot partition and mount it along with your other ones. The following is a modified version of [Pavel Kogan's post](http://www.pavelkogan.com/2014/05/23/luks-full-disk-encryption/) on encrypting `/boot`.  

###1. Boot your Arch installation image.

Download the latest image [here](https://www.archlinux.org/download/) and be sure to verify the image after it is downloaded. After all, encryption is pointless if the installation image itself is compromised.  

Burn the image to disk or copy it to a USB. Then, boot from it.  
 

###2. Create your partitions. 
You'll first need to do the steps already outlined on the Arch Wiki [installation guide](https://wiki.archlinux.org/index.php/Beginners%27_guide) up to partition creation. Basically, set up your network interface an identify the devices within the filesystem.  


The following will create three partitions for `swap`, `home`. and `root`. Replace the `X` of `/dev/sdX` with the letter corresponding to the hard drive you are installing on. Modify the code as suits your needs. 

{% highlight bash %}
parted -s /dev/sdX mklabel msdos
parted -s /dev/sdX mkpart primary 2048s 100%
cryptsetup luksFormat /dev/sdX1
cryptsetup luksOpen /dev/sdX1 lvm
pvcreate /dev/mapper/lvm
vgcreate vg /dev/mapper/lvm
lvcreate -L 4G vg -n swap
lvcreate -L 20G vg -n root
lvcreate -l +100%FREE vg -n home
mkswap -L swap /dev/mapper/vg-swap
mkfs.ext4 /dev/mapper/vg-root
mkfs.ext4 /dev/mapper/vg-home
mount /dev/mapper/vg-root /mnt
mkdir /mnt/home
mount /dev/mapper/vg-home /mnt/home
{% endhighlight %}

These instructions are copied basically verbatim from the blog mentioned at the beginning.  

###3. Install Arch Linux. 
Now, follow the generic [install instructions](https://wiki.archlinux.org/index.php/Beginners%27_guide#Install_the_base_system). Don't forget to generate the fstab.  

When you install the kernel, you'll need to add some modules to the `initramfs` image. Open `/etc/mkinitcpio.conf` and `encrypt` and `lvm2` to the kernel build hooks. The order shouldn't matter, but just in case, edit the line so that it read like: 

{% highlight tex %}
HOOKS="base udev autodetect modconf block encrypt lvm2 filesystems keyboard fsck"
{% endhighlight %}

**NOTE:** The `HOOKS` variable shown above was only intended to demonstrate where `encrypt` and `lvm2` are to be inserted. If the other parameters look different or are in a different order in your config file, **leave them alone**.  


The modules added to the build hooks are necessary for the initramfs to be able to decrypt partitions and mount the filesystem they live on. Save your changes to `mkinitcpio.conf` and rebuild the kernel image. Run:  
{% highlight bash %}
mkinitcpio -p linux
{% endhighlight %}

###4. Install GRUB. 

Continue with the install instructions until you set to the part that tells you how to install a bootloader. Install GRUB as you normally would. Then, open `/etc/default/grub` and add the line: 
{% highlight tex %}
GRUB_ENABLE_CRYPTODISK=y
{% endhighlight %}

Then, also in `/etc/default/grub`, edit `GRUB_CMDLINE_LINUX` to pass extra boot parameters to the kernel: 
{% highlight tex %}
GRUB_CMDLINE_LINUX="cryptdevice=/dev/sdX1:lvm root=/dev/mapper/vg-root"
{% endhighlight %}

Note that if you have an SSD and don't mind the security implications of allowing discards, do this:
{% highlight tex %}
GRUB_CMDLINE_LINUX="cryptdevice=/dev/sdX1:lvm:allow-discards root=/dev/mapper/vg-root"
{% endhighlight %}

Then, regenerate the GRUB config file:
{% highlight bash %}
grub-mkconfig -o /boot/grub.cfg
{% endhighlight %}

You now have a working encrypted system, assuming this tutorial doesn't omit steps or contain catastrophic typos.   

###5. (Optional) Create LUKS key.  

If you booted your system already, you'll notice that you have to enter your LUKS password each time you try to decrypt a block device. It gets annoying after a bit, but you can get around it by supplying a keyfile to the kernel that'll boot the decrypt partitions after you decrypt the bootloader. This doesn't carry security implications because until you enter the password in GRUB, the keyfile is encrypted on the hard drive. 

The only security hazards the key poses is when the system is booted and the key resides in the ramfs, unencrypted. At this point, so does the LUKS master key, so if attackers can get hold of your keyfile in this state, they might as well get your master key. If an attacker is that determined and pernicious, you'll need to do a lot more to secure your system, something well beyond the point of this post and my capacity for explanation.  

Generate the keyfile by doing the following:  


####1. Fill a file with random bits.
{% highlight bash %}
dd bs=512 count=4 if=/dev/urandom of=/crypto_keyfile.bin
cryptsetup luksAddkey /dev/sdX1 /crypto_keyfile.bin
{% endhighlight %}

You can stick `crypto_keyfile.bin` anywhere in the root partition if you'd like. Also, adding the key will prompt you for a password. Enter any existing LUKS password.  

####2. Build the key into the initramfs.
Add the key to the `FILES` parameter in `/etc/mkinitcpio.conf`. Then regenerate the initramfs image by:  
{% highlight bash %}
mkinitcpio -p linux
{% endhighlight %} 
 

####3. Add the key to GRUB.  
Open `/etc/default/grub` and **append** `GRUB_CMDLINE_LINUX` with `cryptkey=rootfs:/crypto_keyfile.bin`. **Do not delete the cryptdevice parts added earlier!!!** 

Then, regenerate the grub.cfg file with `grub-mkconfig`. 

Now, the key will be loaded into the boot image and decrypt your partitions once you select a kernel from the GRUB boot menu.  

