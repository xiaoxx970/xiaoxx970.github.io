---
title: 【一键脚本】frps一键安装脚本——使用systemctl控制
date: 2019-10-24 18:37:47
tags:
---

```sh
FRP_VER=0.29.0
echo "开始安装frps"
wget https://github.com/fatedier/frp/releases/download/v${FRP_VER}/frp_${FRP_VER}_linux_amd64.tar.gz
tar -xvf frp\_$FRP_VER\_linux_amd64.tar.gz && \
rm -f frp_{$FRP_VER}_linux_amd64.tar.gz
sudo mkdir /etc/frp/ /usr/local/bin/frp/
sudo mv frp_${FRP_VER}_linux_amd64/frps /usr/local/bin/frp/
sudo tee /etc/frp/frps.ini <<-'EOF'
[common]
server_addr = hub.xiaoxx.cc
server_port = 7000
bind_udp_port = 7001
kcp_bind_port = 7000
dashboard_port = 7500
subdomain_host = hub.xiaoxx.cc
vhost_http_port = 8080
EOF
sudo tee /etc/systemd/system/frps.service <<-'EOF'
[Unit]
Description=frps daemon
After=syslog.target  network.target
Wants=network.target
[Service]
Type=simple
TimeoutStartSec=30
ExecStart=/usr/local/bin/frp/frps -c /etc/frp/frps.ini
Restart= always
RestartSec=1min
ExecStop=/usr/bin/killall frps
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable frps
sudo systemctl start frps
systemctl status frps
```

# frpc.ini
```
[web]
type = http
local_port = 80
subdomain = test
```