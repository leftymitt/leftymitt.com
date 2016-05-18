---
title: "install whonix kvm on arch linux."
layout: post
category: resources
author: leftymitt
format: text
type: article
tags: 
 - privacy
 - anonymity
 - tor

added_date: "2016-05-20"
published_date: 
icon: whonix-logo.png

code: 
 - script: install_whonix_deps.sh
   language: bash
 - script: install_whonix_kvm.sh
   language: bash
 - script: uninstall_whonix_kvm.sh
   language: bash

whonix_version: 12.0.0.3.2
---

[Whonix](https://www.whonix.org/) is a privacy and security-oriented operating system based on virtual machines (VMs). 
Users launch two VMs, one a general workstation and the other a router that tunnels all outgoing workstation internet traffic through Tor. 
The goal is to combine Tor's privacy protections with the security-by-isolation concept from virtualizing hardware. 

Several implementations exist that use different virtualization software. 
By far the most secure is Qubes, a Linux-based operating system that takes the security-by-isolation approach to its extremes by running all applications within separate user-defined light VMs. 
Look through Qubes's documentation for more information. 

Without virtualizing everything, the next best approach is to run Whonix VMs via userspace virtualization applications, particularly VirtualBox, QEMU or KVM. 
VirtualBox is a proprietary but free-to-use tool developed by Oracle. 
Using it to install Whonix is incredibly easy, but due to its closed-source nature and Oracle's poor reputation for disclosing and fixing security issues, it's [not recommended](https://www.whonix.org/wiki/KVM#Why_Use_KVM_Over_VirtualBox.3F) when you need production-level security that defends against actual threats. 
In that scenario, one must at a minimum rely on free, open-source software, where users can fix bugs themselves whenever they're found. 

[KVM](http://www.linux-kvm.org/page/Main_Page), the kernel-based virtual machine, is an open-source virtualization tool built as a kernel module. 
While it is not as feature-rich as VirtualBox, it can use processor-level virtualization technology ([Intel VT](http://www.cs.columbia.edu/~cdall/candidacy/pdf/Uhlig2005.pdf) and AMD-V), so it won't run on compatible processors so slowly it's rendered unusable. 

Note that this does not take into account the security implications of different graphics virtualization technologies (GVTs). 
No CPU exists that can fully emulate a GPU, so graphics virtualization requires a driver that allows hardware access. 
The drivers, [which themselves may be proprietary](https://software.intel.com/en-us/blogs/2014/05/02/intel-graphics-virtualization-update), often rely on an API provided by the blob that runs the GPU.
The security implications of this are left here as purely speculative. 

Whonix provides its own documentation for downloading and installing its KVM-compatible images, but it could be clearer.
The following are instructions for installing KVM on Arch and Arch-based Linux distributions: 


### 1. Install KVM and Virtual Machine Manager. 

{% highlight bash %}
sudo pacman -Syu
sudo pacman -S qemu libvirt virt-manager
{% endhighlight %}

Also, enable the libvirtd systemd unit and add yourself to the kvm group. 

{% highlight bash %}
sudo systemctl enable libvirtd.service
sudo usermod -aG ${whomai} kvm
{% endhighlight %}

You may need to reboot your computer afterward. 
By default, libvirt uses polkit for managing privileges, and authentication may not get set up correctly. 

### 2. Download and verify the Whonix packages.

Download the Whonix VM images from the website. 
Also, download the signatures, and if you haven't already, download and import Patrick's GPG key. 
You'll need it to [verify the Whonix images](https://www.whonix.org/wiki/Whonix_Signing_Key).  

Note: If you have tor installed (`sudo pacman -S tor`), you can tunnel wget through it while downloading everything. 
If it's not installed and/or you don't want to wait, omit the 'torify' from the commands below: 

{% highlight bash %}
torify wget https://www.whonix.org/download/{{ page.whonix_version }}/Whonix-Gateway-{{ page.whonix_version }}.libvirt.xz
torify wget https://www.whonix.org/download/{{ page.whonix_version }}/Whonix-Workstation-{{ page.whonix_version }}.libvirt.xz
torify wget https://www.whonix.org/download/{{ page.whonix_version }}/Whonix-Gateway-{{ page.whonix_version }}.libvirt.xz.asc
torify wget https://www.whonix.org/download/{{ page.whonix_version }}/Whonix-Workstation-{{ page.whonix_version }}.libvirt.xz.asc
torify wget https://www.whonix.org/patrick.asc
{% endhighlight %}

Optionally, you can check the integrity of the download. 
Import patrick's GPG key and use it to verify the Gateway and Workstation VMs. 

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

You'll find two VMs (Whonix-Workstation and Whonix-Gateway) and three XMLs files. 
The Workstation and Gateway XML contain configuration settings for each respective VM, and the network file defines a network bridge. 

By default, the VM template files assume the VM images are installed in `/var/lib/libvirt/images/`. 
Move the VMs there or edit the XML files with the directory where they will be stored. 
Use absolute paths. 


### 4. Open in virt-manager. 

Open the Virtual Machine Manager (virt-manager) application. 
All applications in the Workstation will be tunneled through the Gateway, which functions as a Tor router. 

<img class="uk-align-center" alt="Virtual Machine Manager UI" 
     src="{{ site.images }}/virt-manager-whonix.png">


### 5. (Optional) Create shared folder. 

It is possible to share files between files on the host and the guest. 
Open the Workstation VM (but do not start it), and switch to the hardware details tab. 

<img class="uk-align-center" alt="Virtual Machine Manager UI" 
     src="{{ site.images }}/virt-manager-hwinfo.png">

At the bottom of the sidebar, click the "Add Hardware" option. 
This will open a new dialog.  
Select the "Filesystem" option, change the mode combobox to "Squash", and set the source and target paths to some location in your filesystem, respectively set below as /tmp/kvmshare and /kvmshare. 

<img class="uk-align-center" alt="Virtual Machine Manager UI" 
     src="{{ site.images }}/virt-manager-new-hw.png">

Open a terminal in the guest and run: 

{% highlight bash %}
mkdir /tmp/kvm_files
mount -t 9p -o trans=virtio,version=9p2000.L /kvmshare /tmp/kvm_files
{% endhighlight %}

Replace "kvmshare" with the path specified in the "Target path" field. 

Files in the host will be available read-only in the guest. 
To edit the files in the VM, copy the files from the mounted subdevice to the guest filesystem. 
