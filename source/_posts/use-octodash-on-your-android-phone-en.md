---
title: Octodash works with octo4a? Yes!
date: 2022-06-07 20:55:56
tags: 
 - 3D
 - Octoprint
 - English Article
---

{% note info no-icon%}

[Octodash](https://unchartedbull.github.io/OctoDash/index.html) uses [Electron](https://en.wikipedia.org/wiki/Electron_(software_framework)) to present the interface and only runs on Windows, Linux and macOS. Obviously doesn't run on Android, but you can run Linux on your Android phone if you want, so that you can run Electron!

{% endnote %}

## Introduction

We all know that using the [Octo4a](https://github.com/feelfreelinux/octo4a) APP allows you to install [Octoprint](https://octoprint.org/) on your Android phone (If you don't know, take a look at [[YouTube]How to run OctoPrint on your phone!](https://www.youtube.com/watch?v=74xdib_-X38&ab_channel=ThomasSanladerer)), so you can use your phone as a controller to control your 3D printer. But if you want to check the state of your printer or do some  manipulation, you can only do it by opening the management page of Octoprint through the browser. Although the display layout on the mobile phone can be optimized after installing the Custom UI plugin, you still need to scroll to see more Information. It would be so much nicer if Octodash can run on your phone. Now I did it, I’m sharing the steps with you, hope that it will help you achieve this.

![IMG_3031](https://xiaoxx.oss-cn-beijing.aliyuncs.com/blog-img/use-octodash-on-your-android-phone/IMG_3031.jpeg)

<!--more-->

## Ideas

1. You need an Android phone that has Octoprint installed and configured
2. Install [Termux](https://termux.com/) on your phone
3. Install the [PRoot](https://wiki.termux.com/wiki/PRoot) distribution for Debian in Termux
4. Install Octodash in Debian
5. Install Xserver XSDL on your phone
6. Test running Octodash under Debian in Termux
7. Add Octodash as a service in Termux and enable automatic startup
8. Done, use Octodash in Xserver XSDL

## Start

### Install Termux

Download and install the latest version of Termux from [`Github Releases`](https://github.com/termux/termux-app/releases). If you have the ability, you can start the `SSH` server to facilitate the next operations from the computer.

### Install and enter the Debian system

```sh
pkg install proot-distro
proot-distro install debian
proot-distro login debian --termux-home
```

### Install Octodash

- Install dependencies

  Made some modifications to the commands of the [installation guide](https://github.com/UnchartedBull/OctoDash/wiki/Installation#manual-installation) to suit the current system

  ```sh
  apt update -y
  apt install -y libgtk-3-0 libnotify4 libnss3 libxss1 libxtst6 xdg-utils libatspi2.0-0 libuuid1 libsecret-1-0 libasound2 libgirepository-1.0-1 gir1.2-glib-2.0 libayatana-appindicator3-1
  ```

- Download and install the latest version of Octodash (replace the download link with the link on the [`Github Releases`](https://github.com/UnchartedBull/OctoDash/releases) page for the latest version)

  ```sh
  wget -O octodash.deb https://github.com/UnchartedBull/OctoDash/releases/download/v2.3.1/octodash_2.3.1_arm64.deb
  dpkg -i octodash.deb
  ```

- Install Xserver

  ```sh
  apt install -y xserver-xorg x11-xserver-utils xinit libgtk-3-0
  ```

### Install Xserver XSDL

Install the latest version of Xserver XSDL from [`Google Play Store`](https://play.google.com/store/apps/details?id=x.org.server)

After installation, open the APP, press `Change device config` button during app start, select `Mouse emulation` -> `Mode` -> `Desktop`.

Return to the startup page after completion, wait until connection info shows up like below, remember the port number, for example, mine is `4713`.

![Screenshot_2022-06-03-19-54-14-504_x.org.server](https://xiaoxx.oss-cn-beijing.aliyuncs.com/blog-img/use-octodash-on-your-android-phone/Screenshot_2022-06-03-19-54-14-504_x.org.server.jpg)

### Test Octodash

Go back to the Debian system under Termux and create the script file (if your port is different from mine, replace it)

```sh
cat << EOF > /root/startdash.sh
#!/bin/bash
export DISPLAY=127.0.0.1:0
export PLUSE_SERVER=tcp:127.0.0.1:4713

octodash --no-sandbox 2>&1
EOF
chmod +x /root/startdash.sh
```

Run the script file to test if Octodash is working properly

```sh
/root/startdash.sh
```

If you see that there is information output and no error is reported, switch back to the Xserver XSDL APP to check whether the initial page of Octodash is displayed at this time.

![OctoPi with OctoDash on RPi 4 with HyperPixel 4.0 - Maurice Kevenaar's  Techblog](https://xiaoxx.oss-cn-beijing.aliyuncs.com/blog-img/use-octodash-on-your-android-phone/332-OctoDashSetup-01.png)

If you see it, don't rush to set it up. After the test is passed, you need the next step: Add Octodash to the Termux service to ensure that it runs in the background.

### Configure the Octodash service

Return to Termux app, first `Ctrl+C` exit the current script, then `Ctrl+D` exit the current terminal, return to the Termux terminal, and continue the following operations.

After ensuring that you have returned to the Termux system, install the termux-services package to enable Termux to support services

```sh
pkg install termux-services
```

Create a service for Octodash

```sh
mkdir -p $PREFIX/var/service/octodash/log
ln -sf $PREFIX/share/termux-services/svlogger $PREFIX/var/service/octodash/log/run
cat << EOF > $PREFIX/var/service/octodash/run
#!/data/data/com.termux/files/usr/bin/sh
exec proot-distro login debian --termux-home -- /root/startdash.sh
EOF
chmod +x $PREFIX/var/service/octodash/run
```

Start the Octodash service and set it to start automatically

```sh
sv up octodash
sv-enable octodash
```

> The log files are located at `$PREFIX/var/log/sv/octodash/current`
>
> what can be done with `sv`:
>
> ```sh
> sv up octodash #Start the service 
> sv down octodash #Stop the service 
> sv-disable octodash #Close the service to start automatically
> ```

### Finish

Now you can go back to the Xserver XSDL APP and continue the initialization of Octodash. After the configuration is complete, you can see this interface

> If the printer address 127.0.0.1:5000 cannot be added successfully, enter the LAN IP of the mobile phone to connect to add it.

![Screenshot_2022-06-03-17-06-38-324_x.org.server](https://xiaoxx.oss-cn-beijing.aliyuncs.com/blog-img/use-octodash-on-your-android-phone/Screenshot_2022-06-03-17-06-38-324_x.org.server.jpg)

You're all done, if you archived this, please share your results in the comment!

## Some notes

In the process of configuration, the experience and tips of some problems are summarized:

- If your phone doesn't have battery protection and keeps charging to 100% all the time, your battery will be bulging after a while. It is recommended to download the [Scene 4](https://github.com/helloklf/vtools) mobile phone management tool. In the tool, you can adjust the battery charging strategy. After charging to 90%, stop charging, and continue charging when the battery drops to 70% to protect the battery. Download link: https://github.com/helloklf/vtools/releases

- The Webcam server that comes with Octo4a has the following problems (for MI6):

  - The resolution cannot be set, and the snapshot resolution is extremely low, resulting in a very low resolution of the generated time-lapse video
  - You can enable auto flash when you stream video, but you can't enable it when you take a snapshot
  - The camera emits shutter sound every time a snapshot is triggered, even after change to mute mode

  To sum up, I finally used a separate Webcam software: [IP Webcam](https://play.google.com/store/apps/details?id=com.pas.webcam) , which solved the above problems. It can also modify the configuration on the web page, which is very convenient

  > If you also change the video source, remember to update the system settings in Octodash and the settings of the octolapse plugin at the same time

- Every APP mentioned in this article must set a background lock, and turn off the power saving policy of these APPs to keep it running in the background all the time.
