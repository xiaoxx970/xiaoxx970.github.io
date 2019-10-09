---
title: 使用caddy实现v2ray流量https伪装
date: 2019-10-09 16:45:23
tags:
---
# 安装

## Get caddy

```sh
sudo curl https://getcaddy.com | bash -s personal
```

## Get v2ray

```sh
sudo bash <(curl -L -s https://install.direct/go.sh)
```

# 配置

## 注册caddy服务

这里我使用的是官方提供的脚本 [caddy.service](https://github.com/mholt/caddy/blob/master/dist/init/linux-systemd/caddy.service)，其他系统也可以在[这里](https://github.com/mholt/caddy/tree/master/dist/init)找到相应的脚本。

把这个文件下载到 `/etc/systemd/system/` 。

```sh
sudo curl -s https://raw.githubusercontent.com/mholt/caddy/master/dist/init/linux-systemd/caddy.service -o /etc/systemd/system/caddy.service
```

创建所需目录，我图方便没有修改脚本直接使用默认值了，如果有特殊需求，可以自己更改目录。

```sh
sudo mkdir /etc/caddy
sudo chown -R root:www-data /etc/caddy
sudo touch /etc/caddy/Caddyfile

sudo mkdir /etc/ssl/caddy
sudo chown -R www-data:root /etc/ssl/caddy
sudo chmod 0770 /etc/ssl/caddy

sudo mkdir /var/www
sudo chown www-data:www-data /var/www
```

上面创建了三个目录，`/etc/caddy` 用了存放 Caddy 的配置文件，`/etc/ssl/caddy` 存放证书，`/var/www` 是默认的网站目录。

接着，重新加载 `systemd daemon`，让配置生效。

```sh
sudo systemctl daemon-reload
```

让 Caddy 开机自启。

```sh
sudo systemctl enable caddy.service
```

至此，Caddy 已经成功注册服务，并能够开机自启了。

## 配置Caddyfile

修改`/etc/caddy/Caddyfile`文件内容如下，用来配置反向代理：

```json
mydomain.me
{
  log /var/log/caddy.log
  proxy /ray localhost:10000 {
    websocket
    header_upstream -Origin
  }
}
```

## 配置v2ray conf

```json
{
  "inbounds": [
    {
      "port": 10000,
      "listen":"127.0.0.1",//只监听 127.0.0.1，避免除本机外的机器探测到开放了 10000 端口
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "b831381d-6324-4d53-ad4f-8cda48b30811",
            "alterId": 64
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
        "path": "/ray"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}
```

