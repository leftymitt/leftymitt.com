---
title: "install whonix via kvm on arch linux."
layout: post
category: resources
author: leftymitt
format: text
type: article
tags: 
 - privacy
 - anonymity
 - tor

date: 2016-04-02

icon: whonix-logo.svg

code: 
 - script: install_whonix_deps.sh
   language: bash
 - script: install_whonix_kvm.sh
   language: bash
 - script: uninstall_whonix_kvm.sh
   language: bash

whonix_version: 13.0.0.1.4
---

[Whonix](https://www.whonix.org/) is a privacy and security-oriented operating
system that utilized Tor and two virtual machines (VMs) to anonymize internet
connections within an sandboxed environment. One VM serves as a general desktop
enviornment (Debian 8 + KDE), and the other serves as a router through which
all internet traffic from the workstation is routed. The setup is analogous to
setting up a remote staging server to route traffic over Tor but with the added
benefit of security-by-isolation via the virtualized hardware. VMs also add
benefits, such as making installations easy to edit, copy, and destroy, but
they also necessitate understanding of various benefits and limitations of
existing virtualization technologies. 

Whonix is presently compatible with several virtualization systems. By far the
most secure is Qubes, a Linux-based operating system that takes the
security-by-isolation approach to its extremes by running all applications
within separate user-defined VMs. Each workspace VM can have its own
permissions and network rules, and all applications running within one are
sandboxes from others. Full documentation is available online information. 

For those using more conventional desktop operating systems, one option is to
run Whonix VMs via userspace virtualization applications, such as VirtualBox or
KVM. VirtualBox is a proprietary but free-to-use tool developed by Oracle.
Install it in Linux via your distributions repositories or in Windows and MacOS
by downloading the installer online. The process is very easy, but due to its
closed-source nature and Oracle's poor reputation for disclosing and fixing
security issues, it's [not
recommended](https://www.whonix.org/wiki/KVM#Why_Use_KVM_Over_VirtualBox.3F)
when you need production-level security. If your threat model requires not
relying on software what may have hidden, undisclosed exploits or built-in
backdoors, you must at a minimum reply on free and open source software. 

[KVM](http://www.linux-kvm.org/page/Main_Page), the kernel-based virtual
machine, is an open-source virtualization tool built into the Linux as a
loadable kernel module. While KVM is not as feature-rich as VirtualBox,
it can use processor-level virtualization technology (see [Intel
VT](http://www.cs.columbia.edu/~cdall/candidacy/pdf/Uhlig2005.pdf) and AMD-V),
so it won't run so slowly to be rendered unusable. Note that this applies to
x86 CPU architectures. Details for POWER and other architectures are not
discussed here. 

Also note that this does not take into account the security implications of
different graphics virtualization technologies (GVTs). No CPU exists that can
fully emulate a GPU, so graphics virtualization requires a driver that allows
hardware access. The drivers, [which themselves may be
proprietary](https://software.intel.com/en-us/blogs/2014/05/02/intel-graphics-virtualization-update),
often rely on an API provided by the blob that runs the GPU. The security
implications of this are left here as purely speculative. 

For Linux users, Whonix provides sufficient documentation for downloading and
installing its KVM-compatible images. The following are instructions for
installing KVM on Arch Linux: 


### 1. Install KVM and Virtual Machine Manager. 

{% highlight bash %}
sudo pacman -Syu
sudo pacman -S qemu libvirt virt-manager
{% endhighlight %}

Once installed, you will need to enable the libvirtd systemd unit and then add
yourself to the kvm group. Otherwise, all libvirt operations will have to be
run as root. 

{% highlight bash %}
sudo systemctl enable libvirtd.service
sudo usermod -aG ${whoami} kvm
{% endhighlight %}

In Arch Linux, virt-manager by default changes the ownership of each disk image
to user `nobody` and group `kvm` while running images. If you install your
images in /var/lib/libvirt/images/, this is not an issue, but you will run into
permissions errors if you instead install KVM images in non-standard locations,
such as ~/.local/libvirt/images. To get around this, enable dynamic ownership
by opening the file /etc/libvirt/qemu.conf and setting (or uncommenting):

{% highlight bash %}
dynamic_ownership = 1
{% endhighlight %}

Users that use separate home and root partitions should consider doing this
because the two Whonix images can dynamically resize to up to 100 GB each, and
over time, imaged installed in /var/lib/libvirt/images/ will fill up your root
partition. 

You may need to reboot your computer afterward. By default, libvirt uses
polkit for managing privileges, and authentication may not get set up
correctly until you reboot.


### 2. Download and verify the Whonix packages.

Download the Whonix VM images from the website. Also, download the signatures,
and if you haven't already, download and import Patrick's GPG key. You'll need
it to [verify the Whonix
images](https://www.whonix.org/wiki/Whonix_Signing_Key). 

{% highlight bash %}
wget https://download.whonix.org/linux/{{ page.whonix_version }}/Whonix-Gateway-{{ page.whonix_version }}.libvirt.xz
wget https://download.whonix.org/linux/{{ page.whonix_version }}/Whonix-Workstation-{{ page.whonix_version }}.libvirt.xz
wget https://download.whonix.org/linux/{{ page.whonix_version }}/Whonix-Gateway-{{ page.whonix_version }}.libvirt.xz.asc
wget https://download.whonix.org/linux/{{ page.whonix_version }}/Whonix-Workstation-{{ page.whonix_version }}.libvirt.xz.asc
wget https://www.whonix.org/patrick.asc
{% endhighlight %}

Note: If you have Tor installed (`sudo pacman -S tor torsocks`), you can prefix
each wget command below with `torify` to tunnel yours download through Tor.
This allows you to hide your Whonix download from your ISP or anyone watching
your connection. If doing this, you should also use `tor-resolve` to avoid DNS
lookups leaking your IP address. 

Now, check the integrity of the download. Import Patrick's GPG key and check
the fingerprint to ensure that it is correct. Then, use it to verify the
Gateway and Workstation VMs. 

{% highlight bash %}
gpg --with-fingerprint patrick.asc # check the fingerprint
gpg --import patrick.asc

gpg --verify Whonix-Gateway-{{ page.whonix_version }}.libvirt.xz.asc Whonix-Gateway-{{ page.whonix_version }}.libvirt.xz
gpg --verify Whonix-Workstation-{{ page.whonix_version }}.libvirt.xz.asc Whonix-Workstation-{{ page.whonix_version }}.libvirt.xz
{% endhighlight %}


### 3. Extract the downloaded archives and move them to the proper directories. 

Go to wherever the files were downloaded and run:

{% highlight bash %}
tar xf Whonix-Gateway-{{ page.whonix_version }}.libvirt.xz
tar xf Whonix-Workstation-{{ page.whonix_version }}.libvirt.xz
{% endhighlight %}

You'll find two VMs (the Whonix-Workstation and Whonix-Gateway qcow2 files) and
three XML files. The Workstation and Gateway XML contain configuration settings
for each respective VM, and the network file defines a network bridge. 

The provided XML files define settings for `accel2d` and `accel3d`.
Unfortunately, these options are not currently supported in Arch Linux, and its
libvirt iteration disallows VM settings that include non-supported options.
Open up Whonix-Workstation and Whonix-Gateway XML files and remove/comment out: 

{% highlight xml %}
<acceleration accel3d='yes' accel2d='yes'/>
{% endhighlight %}

While you have the XML files open, you can also change the installation
directory for your image. By default, the XML files are set to assume the VM
images are installed in `/var/lib/libvirt/images/`. If you intend to install
the VM images in another location, change the paths in both the workstation and
gateway files to your desired path (use absolute paths): 

{% highlight xml %}
<!-- in Whonix-Gateway-{{ page.whonix_version }}.xml -->
<source file='/var/lib/libvirt/images/Whonix-Gateway.qcow2'/>

<!-- and in Whonix-Workstation-{{ page.whonix_version }}.xml -->
<source file='/var/lib/libvirt/images/Whonix-Workstation.qcow2'/>
{% endhighlight %}

Don't forget to move the VMs to the directory you specified. Note if you copy instead of move the qcow2 images, use the template `rsync --sparse file.qcow2 /path/to/destination`. Without the `--sparse` flag, the copy operation will expand the image file to take up the maximum space it can occupy, which here is 100 GB per image. 


### 4. Use `virsh` to install the images. 

From the terminal, make your virtualization system aware of the Whonix images through the `virsh` tool. First, start the virtual network and then set it to start automatically when logging in: 

{% highlight bash %}
virsh -c qemu:///system net-start default
virsh -c qemu:///system net-autostart default
{% endhighlight %}

Then, define the VMs and network rules:

{% highlight bash %}
virsh -c qemu:///system define Whonix-Gateway-{{ page.whonix_version }}.xml
virsh -c qemu:///system net-define Whonix_network-{{ page.whonix_version }}.xml
virsh -c qemu:///system net-autostart Whonix
virsh -c qemu:///system net-start Whonix
virsh -c qemu:///system define Whonix-Workstation-{{ page.whonix_version }}.xml
{% endhighlight %}

The network rules defined in the Whonix_network XML file set up the VM
tunneling for the Workspace and Gateway, so no additional configuration is
needed. 


### 5. Start the images via virt-manager. 

Open the Virtual Machine Manager (virt-manager) application. 

<img class="uk-align-center" alt="Virtual Machine Manager UI" 
     src="{{ site.images }}/virt-manager-whonix.png">


Follow the startup instructions in the images to set up the Tor connection. 


### 6. (Optional) Create shared folder. 

It is possible to share files between files on the host and the guest. Open the
Workstation VM (but do not start it), and switch to the hardware details tab. 

<img class="uk-align-center" alt="Virtual Machine Manager UI" 
     src="{{ site.images }}/virt-manager-hwinfo.png">

At the bottom of the sidebar, click the "Add Hardware" option. This will open a
new dialog. Select the "Filesystem" option, change the mode combobox to
"Squash", and set the source and target paths to some location in your
filesystem, respectively set below as /tmp/kvmshare and /kvmshare. 

<img class="uk-align-center" alt="Virtual Machine Manager UI" 
     src="{{ site.images }}/virt-manager-new-hw.png">

This will create a mountable filesystem inside your VM that contains the
contents of the /tmp/kvmshare directory on the host system. To mount the
filesystem, open a terminal in the guest and run: 

{% highlight bash %}
mkdir -p /tmp/kvmshare
mount -t 9p -o trans=virtio,version=9p2000.L /kvmshare /tmp/kvmshare
{% endhighlight %}

This mounts the /kvmshare filesystem defined in the "Target path" field in the
virt-manager menu as /tmp/kvmshare within the VM. Files in the host will be
available read-only in the guest. To edit the files in the VM, copy the files
from the mounted subdevice to the guest filesystem. 
