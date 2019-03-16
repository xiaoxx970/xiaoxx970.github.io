---
title: 树莓派：samba文件共享、frp内网穿透、lighttpd、aria2c下载器（AriaNg前端）安装教程
date: 2018-3-12 1:08:00
tags: 各种Pi
---
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;最近拿到了一个树莓派3B，想要做成NAS以及下载机，我这个人平时喜欢看美剧，每次下载都要先开电脑打开浏览器找资源迅雷下载，有时候用手机找到资源了还是得开电脑，毕竟手机不适合用来下BT，于是有了这个想法，一开始还装了[Nextcloud的树莓派版](https://ownyourbits.com/nextcloudpi/)(需要的童鞋可以进去看（需翻墙）)（2018-12-20更新：现在看官网把这个部分已经做的很完善了，占用可能也不高了），网盘下载前端倒是什么都有了，就是觉着太臃肿，web服务器用的居然还是apache，占用可想而知，到后来每次链接ssh都要接近半分钟，运行一个python脚本更是要到一分钟，那就是几行的脚本啊。后来想nextcloud其实没什么用，我只要能下载和共享文件就可以了。  
<!--more-->
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;于是就有了这个教程，我打算用lighttpd作web服务器，上面放hexo博客（毕竟有了frp）和[aria2c前端](http://ariang.mayswind.net/zh_Hans/)，通过frp连接到我的阿里云主机，那里有公网IP，这样一来我可以在任何地方访问我的树莓派叫它下美剧，真是很幸福的一件事。  

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;废话不多说，下面开始教程，我用的系统是raspbian-stretch-lite，最少占用嘛，桌面也是不需要的。  

# **第一部分：samba文件共享**

* ## 挂载硬盘  

查看设备列表：

```bash
sudo fdisk -l
```

这时候会列出所有挂载的设备（告诉我你已经插上硬盘了）然后找到硬盘的标识，一般是/dev/sda1，然后记下来  
挂载硬盘：

```bash
sudo mount /dev/sda1 /media
```

查看现有磁盘信息，看是否挂载成功:

```bash
df -T
```

* ## 更换软件安装源到国内  

少数情况后面的安装会出现apt-get install安装失败，这个时候就需要把安装源替换成国内源，速度也会更快  

备份原列表

```bash
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
sudo cp /etc/apt/sources.list.d/raspi.list /etc/apt/sources.list.d/raspi.list.bak
```

编辑文件：

```bash
sudo sed -i 's#://raspbian.raspberrypi.org#s://mirrors.tuna.tsinghua.edu.cn/raspbian#g' /etc/apt/sources.list
sudo sed -i 's#://archive.raspberrypi.org/debian#s://mirrors.tuna.tsinghua.edu.cn/raspberrypi#g' /etc/apt/sources.list.d/raspi.list
```

然后执行更新让更改生效:

```bash
sudo apt-get update
```

* ## samba安装及配置

根据需要修改下面配置文件  
[MyNAS]是电脑上可以看到的名称  
共享路径是挂载硬盘的路径所以我用的是/media  
其他可以不用管  
全部复制到终端即可：  
（我用了echo命令来写配置文件，当然用nano、vim、vi都是可以的，看各位喜欢）

```bash
sudo apt-get install samba -y #安装samba
sudo echo "
    # 分享名称
    [MyNAS]
    # 说明信息
    comment = NAS Storage
    # 可以访问的用户
    valid users = pi,root
    # 共享文件的路径。
    path = /media
    # 可被其他人看到资源名称（非内容）
    browseable = yes
    # 可写
    writable = yes
    # 新建文件的权限为 664
    create mask = 0664
    # 新建目录的权限为 775
    directory mask = 0775
"  >> /etc/samba/smb.conf

```

测试配置文件是否有错误，根据提示做相应修改：

```bash
testparm
```
添加登陆账户并创建密码，必须是 linux 已存在的用户，密码不一定要和系统一样，只是登录samba用的。

```bash
sudo smbpasswd -a pi
```

输入两次密码  

重载 samba 服务：

```bash
sudo service samba reload
```

让samba开机启动：

```bash
sudo update-rc.d samba defaults
```

# **第二部分：aria2下载器**

* ## aria2配置及安装

安装aria2

```bash
sudo apt-get install aria2 -y
```

创建 session 和配置文件：

```bash
mkdir ~/.aria2
touch ~/.aria2/aria2.session
touch ~/.aria2/aria2.conf
```

写入配置文件aria2.conf,注意如果用户名不是pi的话需要改下面的对应文件路径：

```bash
echo "

## 文件保存相关 ##

# 文件保存目录
dir=/media/Download
# 启用磁盘缓存, 0为禁用缓存, 需1.16以上版本, 默认:16M
disk-cache=32M
# 断点续传
continue=true

# 文件预分配方式, 能有效降低磁盘碎片, 默认:prealloc
# 预分配所需时间: none < falloc ? trunc < prealloc
# falloc和trunc则需要文件系统和内核支持
# NTFS建议使用falloc, EXT3/4建议trunc, MAC 下需要注释此项
#file-allocation=falloc

## 下载连接相关 ##

# 最大同时下载任务数, 运行时可修改, 默认:5
#max-concurrent-downloads=5
# 同一服务器连接数, 添加时可指定, 默认:1
max-connection-per-server=15
# 整体下载速度限制, 运行时可修改, 默认:0（不限制）
#max-overall-download-limit=0
# 单个任务下载速度限制, 默认:0（不限制）
#max-download-limit=0
# 整体上传速度限制, 运行时可修改, 默认:0（不限制）
#max-overall-upload-limit=0
# 单个任务上传速度限制, 默认:0（不限制）
#max-upload-limit=0
# 禁用IPv6, 默认:false
disable-ipv6=true

# 最小文件分片大小, 添加时可指定, 取值范围1M -1024M, 默认:20M
# 假定size=10M, 文件为20MiB 则使用两个来源下载; 文件为15MiB 则使用一个来源下载
min-split-size=10M
# 单个任务最大线程数, 添加时可指定, 默认:5
split=10

## 进度保存相关 ##

# 从会话文件中读取下载任务
input-file=/home/pi/.aria2/aria2.session
# 在Aria2退出时保存错误的、未完成的下载任务到会话文件
save-session=/home/pi/.aria2/aria2.session
# 定时保存会话, 0为退出时才保存, 需1.16.1以上版本, 默认:0
save-session-interval=60

## RPC相关设置 ##

# 启用RPC, 默认:false
enable-rpc=true
# 允许所有来源, 默认:false
rpc-allow-origin-all=true
# 允许外部访问, 默认:false
rpc-listen-all=true
# RPC端口, 仅当默认端口被占用时修改
# rpc-listen-port=6800
# 设置的RPC授权令牌, v1.18.4新增功能, 取代 --rpc-user 和 --rpc-passwd 选项
#rpc-secret=<TOKEN>

## BT/PT下载相关 ##

# 当下载的是一个种子(以.torrent结尾)时, 自动开始BT任务, 默认:true
#follow-torrent=true
# 客户端伪装, PT需要
peer-id-prefix=-TR2770-
user-agent=Transmission/2.77
# 强制保存会话, 即使任务已经完成, 默认:false
# 较新的版本开启后会在任务完成后依然保留.aria2文件
#force-save=false
# 继续之前的BT任务时, 无需再次校验, 默认:false
bt-seed-unverified=true
# 保存磁力链接元数据为种子文件(.torrent文件), 默认:false
bt-save-metadata=true
" >> ~/.aria2/aria2.conf
```

然后执行：

```bash
aria2c --conf-path=/home/pi/.aria2/aria2.conf -D
```

没有任何提示则表示成功，Ctrl+C退出。  
接下来作为服务添加开机自启，注意路径是否正确：

```bash
sudo tee /etc/init.d/aria2c <<-'EOF'
#!/bin/sh
### BEGIN INIT INFO
# Provides:          aria2
# Required-Start:    $remote_fs $network
# Required-Stop:     $remote_fs $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Aria2 Downloader
### END INIT INFO
do_start()
{
        echo -n "Starting aria2c"
             su pi -c "aria2c --conf-path=/home/pi/.aria2/aria2.conf &"
#这里的路径只能用绝对路径所以用户名不是pi的记得来这里修改
}
do_stop()
{
     echo -n "Shutting down aria2c "
        pkill -f aria2c
}
do_restart() {
    do_stop
    sleep 1
    do_start
}
case "$1" in
start)
   do_start
   ;;
stop)
   do_stop
   ;;
status)
  exit $?
  ;;
restart)
  do_restart
  ;;
*)
   echo "Usage: service aria2c {start|stop|status|restart}" >&2
   exit 1
   ;;
esac
exit
EOF
sudo chmod +x /etc/init.d/aria2c
sudo update-rc.d aria2c defaults
sudo service aria2c start
```

这个时候aria2已经添加到开机启动并已经启动  
以后想要管理aria2只需要输入对应命令即可

```bash
#启动aria2服务
sudo service aria2c start 
#停止aria2服务
sudo service aria2c stop 
#查看aria2服务状态
sudo service aria2c status 
```
同样的命令把aria2c替换成其他名称用来管理samba和等下要装的frp都是可以的  

> 参考：https://www.jianshu.com/p/03f8022453a5

* ## 网页前端（lighttpd和[ariaNg](http://ariang.mayswind.net/zh_Hans/)）

安装lighttpd并设为默认启动：  

```bash
sudo apt-get install lighttpd -y
sudo update-rc.d lighttpd defaults
```

安装好lighttpd后默认已经开启网页服务，接下来放aria2前端

```bash
cd /var/www/html
sudo wget https://github.com/mayswind/AriaNg/releases/download/0.4.0/aria-ng-0.4.0.zip
sudo unzip aria-ng-0.4.0.zip
#顺便删除压缩包
rm aria-ng-0.4.0.zip
```

现在用浏览器打开树莓派IP，你就可以看到一个漂亮的前端,以后就用它管理下载  
至此，一个内网NAS已经搭建完成，轻量化，超小占用。  
当然还没完，我们要做的是能从外网访问的下载器。
</br>

# **第三部分：内网穿透frp**  

关于frp

英文全称：fast reverse proxy
中文全称：快速反向代理
简称：frp
frp 是一个可用于内网穿透的高性能反向代理应用，支持 tcp, udp, http, https 协议.

frp 的作用
利用处于内网或防火墙后的机器，对外网环境提供 http 或 https 服务。
对于 http, https 服务支持基于域名的虚拟主机，支持自定义域名绑定，使多个域名可以共用一个80端口。
利用处于内网或防火墙后的机器，对外网环境提供 tcp 和 udp 服务，例如在家里通过 ssh 访问处于公司内网环境内的主机。

frp为免费且开源项目，需要自己利用一台拥有公网IP机器搭建服务端，以部署内网穿透项目。

项目链接：https://github.com/fatedier/frp/

科普完了,没有公网IP服务器的童鞋这里推荐一个免费的公共服务:https://www.nat.ee/

* ## frp客户端安装

可以自己到[releases](http://github.com/fatedier/frp/releases)页面找最新版链接

```bash
cd ~
wget http://github.com/fatedier/frp/releases/download/v0.16.0/frp_0.16.0_linux_arm.tar.gz
tar -xvf frp_0.16.0_linux_arm.tar.gz
sudo mv frp_0.16.0_linux_arm/ /etc/frp
```

编辑配置文件

```bash
sudo nano /etc/frp/frpc.ini
```

根据nat.ee提供的配置文件,这里提供一个http的例子  
把中文都换掉,自定义域太简单可能会因为被占用无法启动,记得换个复杂点的

```bash
#http-自定义配置-示例
[common]
server_addr = nat.ee
server_port = 7000
privilege_token = www.nat.ee
user = 自定义用户名称

[自定义服务名称]
type = http
local_port = 80
local_ip = 127.0.0.1
custom_domains = 自定义域.nat.ee
```  

Ctrl+O保存，Ctrl+X退出  
测试一下是否运行正常:  

```bash
sudo /etc/frp/frpc -c /etc/frp/frpc.ini
```

如果输出结果带有"start proxy success"则表示连接成功  
Ctrl+C关闭  
添加frp为服务并自动启动:  
(我在里面加了判断网络是否连接的脚本"net_ts",终于解决了开机启动时没网络导致启动失败的问题)

```bash
sudo tee /etc/init.d/frp <<-'EOF'
#!/bin/sh
### BEGIN INIT INFO
# Provides:         frp
# Required-Start:    $network $local_fs $remote_fs $named $portmap $syslog
# Required-Stop::    $network $local_fs $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start frp at boot time
# Description:       A porxy clint
### END INIT INFO
net_ts()
{
    #超时时间
    timeout=5

    #目标网站
    target=baidu.com

    #获取响应状态码
    ret_code=`curl -I -s --connect-timeout $timeout $target -w %{http_code} | tail -n1`

    if [ "x$ret_code" = "x200" ]; then
        echo 网络畅通
	netstate='1'
    else
        echo 网络不畅通
	netstate='0'
    fi
}
do_start()
{
        echo "starting frp."
        /etc/frp/frpc -c /etc/frp/frpc.ini &

}
do_stop()
{
      pkill -f /etc/frp/frpc
      echo "stop complete."
}
do_restart() {
    do_stop
    sleep 1
    do_start
}
case "$1" in
start)
  net_ts
#这里验证网络是否连通，连通了才启动frp
  while [ $netstate -lt 0 ];
  do
    echo 请检查网络，将在5秒后重试
    sleep 5
    net_ts
  done
  do_start
   ;;
stop)
   do_stop
   ;;
status)
  exit $?
  ;;
restart)
  do_restart
  ;;
*)
   echo "Usage:service frp {start|stop|restart|status}" >&2
   exit 1
   ;;
esac
exit 0
EOF

sudo chmod +x /etc/init.d/frp
sudo systemctl daemon-reload
sudo update-rc.d frp defaults
sudo service frp start
```

frp服务已经启动  
现在试试能否从外网访问  
一切正常的话你就可以从外网看到刚才那个漂亮的前端  
开始你的下载吧  
frp还有很多玩法，有兴趣的朋友可以去项目地址看看，有中文说明.  

**第一次写教程,写的不好的地方请多包涵,之后我还会写在树莓派上安装hexo博客的教程,记得来看哦.**
