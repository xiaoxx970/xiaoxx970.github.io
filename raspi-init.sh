#!/bin/bash

sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
sudo cp /etc/apt/sources.list.d/raspi.list /etc/apt/sources.list.d/raspi.list.bak
sudo sed -i 's#://raspbian.raspberrypi.org#s://mirrors.tuna.tsinghua.edu.cn/raspbian#g' /etc/apt/sources.list
sudo sed -i 's#://archive.raspberrypi.org/debian#s://mirrors.tuna.tsinghua.edu.cn/raspberrypi#g' /etc/apt/sources.list.d/raspi.list
sudo apt-get update
sudo apt-get install samba -y
sudo tee -a /etc/samba/smb.conf <<-'EOF'
# 分享名称
[MyNAS]
# 说明信息
comment = NAS Storage
# 可以访问的用户
valid users = pi,root
# 共享文件的路径。
path = /media/Green-EXfat
# 可被其他人看到资源名称（非内容）
browseable = yes
# 可写
writable = yes
# 新建文件的权限为 664
create mask = 0664
# 新建目录的权限为 775
directory mask = 0775
EOF
testparm
echo "samba服务配置完成，请设定密码："
sudo smbpasswd -a pi
sudo service samba reload
sudo update-rc.d samba defaults
echo "开始安装frp"
cd ~
wget https://github.com/fatedier/frp/releases/download/v0.24.1/frp_0.24.1_linux_arm.tar.gz
tar -xvf frp_0.24.1_linux_arm.tar.gz
sudo mv frp_0.24.1_linux_arm/ /etc/frp
sudo mv /etc/frp/frpc.ini /etc/frp/frpc.ini.bak
sudo echo "
[common]
server_addr = ali.mcyo.pw
server_port = 7000

[web]
type = http
local_port = 80
subdomain = pi

[ssh]
type = tcp
local_ip = 127.0.0.1
local_port = 22
remote_port = 6000
"  >> /etc/frp/frpc.ini
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