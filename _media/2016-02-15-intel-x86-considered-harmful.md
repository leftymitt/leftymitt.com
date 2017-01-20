---
title: "intel x86 considered harmful."
layout: post
category: media
author: Joanna Rutowska
format: text
type: report
tags: 
 - qubes
 - security
 - intel

published_date: "2015-10-01"
icon: qubes-logo.svg

link: "http://blog.invisiblethings.org/papers/2015/x86_harmful.pdf"
---

Present-day computer and network security starts with the assumption that there
is a domain that we can trust. For example: if we encrypt data for transport
over the internet, we generally assume the computer that’s doing the encrypting
is not compromised and that there’s some other “endpoint” at which it can be
safely decrypted.

To trust what a program is doing assumes not only trust in that program itself,
but also in the underlying operating system. The program’s view of the world is
limited by what the operating system tells it. It must trust the operating
system to not show the memory contents of what it is working on to anyone else.
The operating system in turn depends on the underlying hardware and firmware
for its operation and view of the world.

So computer and network security in practice starts at the hardware and
firmware underneath the endpoints. Their security provides an upper bound for
the security of anything built on top. In this light, this article examines the
security challenges facing us on modern off-the-shelf hardware, focusing on
Intel x86-based notebooks. The question we will try to answer is: can modern
Intel x86-based platforms be used as trustworthy computing platforms?  
