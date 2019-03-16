---
title: Minecraft海外服务器加速后续：用frp更高效地转发流量（也适用于其他游戏的加速）
date: 2018-11-30 15:51:42
tags: 云服务
---
>前情提要：之前用Nginx反向代理的功能来加速Minecraft，真的是太不稳定！了！
经常出现玩着玩着掉线了，去看Minecraft服务器没有任何毛病，看用来加速的阿里云服务器，也没有任何异常，但是直连Minecraft服务器是可以的，所以问题绝壁出在加速服务器上
重启Nginx，连不上，重启服务器，还是连不上，最后过了几分钟，自己连上了。很任性有没有，如此的情况出了几次实在是忍受不了了，于是在想别的办法，想到一个叫frp的软件，之前用过来做内网穿透，同样也是转发流量的道理嘛，就两边装了试试发现，是真的好用啊，甚至感觉延迟更低了，也没有掉线过

安装过程来介绍一下
<!---more--->
其实也没什么新的东西，就是分别在服务器和加速服务器安装frp，然后配置运行就可以了

# 在Minecraft服务器上安装和配置frp客户端(frpc)

- 下载并解压frp
  
    可以去[release页面](
https://github.com/fatedier/frp/releases/latest)找到最新版的下载链接然后替换下面的链接

    ```bash
    cd ~
    wget https://github.com/fatedier/frp/releases/download/v0.21.0/frp_0.21.0_linux_amd64.tar.gz -O frp.tar.gz
    tar -xvf frp.tar.gz
    ```
- 到frp目录下,复制文件到系统里（以管理员身份运行）
    ```bash
    cd frp
    cp frpc /usr/local/bin/frpc
    mkdir /etc/frp
    cp frpc.ini /etc/frp/frpc.ini
    ```
- 编写frpc的配置文件：`frpc.ini`
    ```bash
    nano /etc/frp/frpc.ini
    # 内容如下
    [common]
    server_addr = 加速服务器的IP或域名
    server_port = 7000
    login_fail_exit	= false  #0.11新功能：登录远程服务器失败不退出，30s自动重试
    #protocol = kcp

    [mc]
    type = tcp
    local_ip = 127.0.0.1
    local_port = 25565
    remote_port = 25565

    [mc-udp]
    type = udp
    local_ip = 127.0.0.1
    local_port = 25565
    remote_port = 25565
    ```
    我也不知道开启udp的必要性，但是经过实测只开tcp并登陆不进游戏

- 编写 frp service 文件，把frpc加入系统服务，这样方便管理
    ```bash
    nano /usr/lib/systemd/system/frpc.service
    # 内容如下
    [Unit]
    Description=frpc
    After=network.target

    [Service]
    TimeoutStartSec=30
    ExecStart=/usr/local/bin/frpc -c /etc/frp/frpc.ini
    ExecStop=/bin/kill $MAINPID

    [Install]
    WantedBy=multi-user.target
    ```
- 设置文件权限，启动 frp 并设置开机启动
    ```bash
    chmod 754 /usr/lib/systemd/system/frpc.service
    systemctl enable frpc
    ```

    好了frp客户端的操作先到这里，等下装好frp服务端并运行后再<a id="back" />回来这里，开启客户端：
    ```bash
    systemctl start frpc
    systemctl status frpc
    ```

# 在加速服务器上安装frp服务端

- 还是一样，先下载frp，再解压
    ```bash
    cd ~
    wget https://github.com/fatedier/frp/releases/download/v0.21.0/frp_0.21.0_linux_amd64.tar.gz -O frp.tar.gz
    tar -xvf frp.tar.gz
    ```
- 到frp目录下,复制文件到系统里（这次是frps了）
    ```bash
    cd frp
    cp frps /usr/local/bin/frps
    mkdir /etc/frp
    cp frps.ini /etc/frp/frps.ini
    ```
- 编写frps的配置文件：`frps.ini`
    ```bash
    nano /etc/frp/frps.ini
    # 内容如下
    [common]
    bind_port = 7000
    ```
    就是这么简单，记得去防火墙允许7000端口
- 加入系统服务
    ```bash
    nano /usr/lib/systemd/system/frps.service
    # 内容如下
    [Unit]
    Description=frps
    After=network.target

    [Service]
    TimeoutStartSec=30
    ExecStart=/usr/local/bin/frps -c /etc/frp/frps.ini
    ExecStop=/bin/kill $MAINPID

    [Install]
    WantedBy=multi-user.target
    ```
    保存退出，设置权限，开机启动
    ```bash
    chmod 754 /usr/lib/systemd/system/frps.service
    systemctl enable frps
    systemctl start frps
    systemctl status frps
    ```
    现在可以[回去](#back)启动客户端了
<br />

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;完成了~最后一句话是显示服务运行状态的,当里面显示绿色的`active`就表示程序正常运行了
客户端那边也是，如果出问题了显示红色的`dead`，那么认真看看系统日志,是不是配置文件不对什么的，然后再`systemctl restart frpc`(s),看`status`，多错几次还是就OK了。

如果你照着我的教程做了，在任何一步出了问题都欢迎在评论里告诉我，看到了一定回复。
>ftp项目地址：https://github.com/fatedier/frp
它能做的不止转发端口流量这么简单，如果你愿意，看看它的中文文档，会有很多收获的