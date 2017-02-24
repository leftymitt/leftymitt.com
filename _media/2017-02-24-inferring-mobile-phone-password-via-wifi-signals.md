---
title: "when csi meets public wifi: inferring your mobile phone password via wifi signals."
layout: post
category: media
author: Mengyuan Li, Yan Meng, Junyi Liu, Haojin Zhu, Xiaohui Liang, Yao Liu, and Na Ruan

format: text
type: science
tags: 
 - security

published_date: 2016-10-24
publisher: fermat's library

link: "http://fermatslibrary.com/s/when-csi-meets-public-wifi-inferring-your-mobile-phone-password-via-wifi-signals"
---

In this study, we present WindTalker, a novel and practical keystroke inference
framework that allows an attacker to infer the sensitive keystrokes on a mobile
device through WiFi-based side-channel information. WindTalker is motivated
from the observation that keystrokes on mobile devices will lead to diﬀerent
hand coverage and the ﬁnger motions, which will introduce a unique interference
to the multi-path signals and can be reﬂected by the channel state information
(CSI). The adversary can exploit the strong correlation between the CSI
ﬂuctuation and the keystrokes to infer the user’s number input. WindTalker
presents a novel approach to collect the target’s CSI data by deploying a
public WiFi hotspot. Compared with the previous keystroke inference approach,
WindTalker neither deploys external devices close to the target device nor
compromises the target device. Instead, it utilizes the public WiFi to collect
user’s CSI data, which is easy-to-deploy and diﬃcult-to-detect. In addition, it
jointly analyzes the traﬃc and the CSI to launch the keystroke inference only
for the sensitive period where password entering occurs. WindTalker can be
launched without the requirement of visually seeing the smart phone user’s
input process, backside motion, or installing any malware on the tablet. We
implemented Windtalker on several mobile phones and performed a detailed case
study to evaluate the practicality of the password inference towards Alipay,
the largest mobile payment platform in the world. The evaluation results show
that the attacker can recover the key with a high successful rate.
