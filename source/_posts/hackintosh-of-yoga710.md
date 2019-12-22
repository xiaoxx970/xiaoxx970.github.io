---
title: MacOS Mojave Hackintosh for Lenovo Yoga710 [clover]
date: 2019-03-02 21:09:51
tags: note
---
I've been attempt making my laptop work with mojave for like one month, and bought a DW1820 wireless card to fix network problem.  Also there was a lot of problem like brightness, bluetooth, app store, etc. It's all work now.
<!--more-->

The most tricky part is to drive DW1820(What? I bought it for hackintosh!), I do found kext driver for my card from RehabMan, but seems not work at all. Every time I boot up I see this

![](https://xiaoxx.oss-cn-beijing.aliyuncs.com/blog-img/hackintosh-of-yoga710/error1.jpg)

Maybe something wrong with Bluetooth since it's connected via inner USB. But I fixed it by just delete `BrcmPatchRAM2.kext` and `BrcmFirmwareData.kext`, and add the address of bluetooth's USB port to `FakePCIID.kext`, it workd fine then. no  need of other kext driver.

#### Here's my hardware:
{% note info %}
**Processor**: Intel Core i5-7200U
**Graphics**: Intel HD Graphics 620, NVDIA Geforce 940MX
**Memory**: 4096 MB, 2133 MHz, DDR4, 1/1 slots occupied, Single-Channel
**Display**: 14 inch 16:9, 1920 x 1080 pixel 157 PPI, Multitouch
**Mainboard**: Intel Kaby Lake-U Premium PCH
{% endnote %}

{% note success %}
#### What works well:
- Graphics, Brightness(and save brightness)
- Keyboard & Trackpad
- Audio
- Battery
- Airprot
- Bluetooth
- HDMI output with audio
- Headphone jack include microphone
{% endnote %}

{% note danger %}
#### What is not working:
- NVDIA Geforce 940MX
- Touch screen
- Sleep function(just about work, it wake immediately after sleep)
- SD card reader
{% endnote %}

{% note default %}
#### Something you need attention:
brightness can be adjust at setting, you can add a key map yourself.
You can enable HIDPI :[one-key-hidpi](https://github.com/xzhih/one-key-hidpi)
{% endnote %}

I'm just put the clover file of myself here, hope there's help for you. As for installing detals, it's alot outside.

Download link: [clover file of yoga 710](CLOVER.zip)
