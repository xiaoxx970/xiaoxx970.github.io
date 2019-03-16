---
title: 装了armbian的Orange pi折腾记录(外接HDMI屏幕分辨率调节及屏幕旋转)
date: 2018-10-8 23:26:00
tags: 各种Pi
---

* ### Armbian orange pi 调节分辨率

    ```bash
    h3disp -m 1080p60 -c 1
    ```

* ### 动态开启/关闭HDMI输出
    ```bash
    sudo su
    cd /sys/kernel/debug/dispdbg/
    echo "switch" > command
    echo "disp" > name
    echo "0 10" > param
    echo "1" > start
    ```
    把parm部分的0改成4就是打开HDMI输出，第二个数字10代表输出分辨率为1080p60，换成5则代表720p60。
<!--more-->
    全部模式列表：
    ```bash
    0 480i
    1 576i
    2 480p
    3 576p
    4 720p 50Hz
    5 720p 60Hz
    6 1080i 50 Hz
    7 1080i 60 Hz
    8 1080p 24 Hz
    9 1080p 50 Hz
    10 1080p 60 Hz
    ```
    各种详细设置:[Fine-Tuning](https://docs.armbian.com/User-Guide_Fine-Tuning/)

* ### 屏幕旋转
    编辑配置文件：
    ```bash
    sudo nano /etc/X11/xorg.conf.d/01-armbian-defaults.conf
    ```
    在末尾加入下面的代码:
    ```bash
    # Append
    Section "Device"
    Identifier "default"
    Driver "fbdev"
    Option "Rotate" "CCW"
    EndSection
    ```
    保存后重启，重启后屏幕就旋转成竖的了。 你可以通过改变``CCW``到``CW``来改变旋转方向。
___

* ### python log用法
    ```py
    import logging
    logging.basicConfig(filename='/root/screen.log', level=logging.INFO, format='%(asctime)s %(message)s', datefmt='[%Y-%m-%d %I:%M:%S %p]')
    logging.info('hi')
    ```
    输出(文件：screen.log)：
    ``[2018-10-08 09:36:36 PM] hi``
    其他用法还有：
    ```py
    logging.debug("debug") 
    logging.info("info") 
    logging.warning("warning") 
    logging.error("error")
    logging.critical("critical")
    ```
    参照：https://docs.python.org/2/howto/logging.html

    进程管理工具Supervisor:[管理Python](https://www.restran.net/2015/10/04/supervisord-tutorial/)

> 习得以上知识所用的时间：230分钟