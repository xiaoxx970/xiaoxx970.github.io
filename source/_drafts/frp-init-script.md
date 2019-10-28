---
title: 【一键脚本】frps一键安装脚本——使用systemctl控制
date: 2019-10-24 18:37:47
tags:
---

```sh
FRP_VER=0.29.0
echo "开始安装frp"
wget https://github.com/fatedier/frp/releases/download/v${FRP_VER}/frp_${FRP_VER}_linux_amd64.tar.gz
tar -xvf frp_{$FRP_VER}_linux_amd64.tar.gz && \
rm -f frp_{$FRP_VER}_linux_amd64.tar.gz
sudo mkdir /etc/frp/ /usr/local/bin/frp/
sudo mv frp_${FRP_VER}_linux_amd64/frpc /usr/local/bin/frp/
sudo tee /etc/frp/frpc.ini <<-'EOF'
[common]
server_addr = ali.mcyo.pw
server_port = 7000
[ssh_njupt]
type = tcp
local_ip = 127.0.0.1
local_port = 22
remote_port = 6422
[web-lab]
type = http
local_ip = 127.0.0.1
local_port = 8888
custom_domains = lab.mcyo.pw
EOF
sudo tee /etc/systemd/system/frpc.service <<-'EOF'
[Unit]
Description=frpc daemon
After=syslog.target  network.target
Wants=network.target
[Service]
Type=simple
ExecStart=/usr/local/bin/frp/frpc -c /etc/frp/frpc.ini
Restart= always
RestartSec=1min
ExecStop=/usr/bin/killall frpc
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable frpc
sudo systemctl start frpc
```

