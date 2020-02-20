title: 使用caddy实现v2ray流量伪装
tags:
  - systemctl
  - note
date: 2019-10-09 16:45:23
---
{% note info no-icon %}
[Caddy](https://dengxiaolong.com/caddy/zh/)：一个方便配置的 web server
{% endnote %}

本质上要做的事情是让caddy做反向代理服务器转发v2ray流量，caddy的好处是自己申请证书实现https，这样伪装成的tls流量更不容易被发现

<!--more-->

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

让caddy拥有非root用户打开端口的权限

```sh
sudo setcap 'cap_net_bind_service=+ep' /usr/local/bin/caddy
```

如果出现`setcap: command not found`那就安装一下`libcap2-bin`：

```sh
sudo apt install libcap2-bin
```

创建用户和所需目录并且只赋予必要的权限

```sh
sudo groupadd -g 33 www-data
sudo useradd \
  -g www-data --no-user-group \
  --home-dir /var/www --no-create-home \
  --shell /usr/sbin/nologin \
  --system --uid 33 www-data

sudo mkdir /etc/ssl/caddy
sudo chown -R root:www-data /etc/ssl/caddy
sudo chmod 0770 /etc/ssl/caddy

sudo touch /var/log/caddy.log
sudo chown root:www-data /var/log/caddy.log
sudo chmod 0770 /var/log/caddy.log

sudo mkdir /etc/caddy
sudo chown -R root:root /etc/caddy
sudo touch /etc/caddy/Caddyfile
sudo chown root:root /etc/caddy/Caddyfile
sudo chmod 644 /etc/caddy/Caddyfile

sudo mkdir /var/www
sudo chown www-data:www-data /var/www
sudo chmod 555 /var/www
```

上面创建了三个目录，`/etc/caddy/Caddyfile` 是 Caddy 的配置文件，`/etc/ssl/caddy` 存放证书，`/var/www` 是默认的网站目录。

把官方提供的脚本 [caddy.service](https://github.com/mholt/caddy/blob/master/dist/init/linux-systemd/caddy.service)下载到 `/etc/systemd/system/` 并重新加载 `systemd daemon`，让配置生效。

```sh
wget https://raw.githubusercontent.com/caddyserver/caddy/master/dist/init/linux-systemd/caddy.service
sudo cp caddy.service /etc/systemd/system/
sudo chown root:root /etc/systemd/system/caddy.service
sudo chmod 644 /etc/systemd/system/caddy.service
sudo systemctl daemon-reload
sudo systemctl start caddy.service
```

让 Caddy 开机自启。

```sh
sudo systemctl enable caddy.service
```

至此，Caddy 已经成功注册服务，并能够开机自启了。

## 配置Caddyfile

修改`/etc/caddy/Caddyfile`文件内容如下，用来配置反向代理，`mydomain.me`替换为你的域名：
（点右上链接后可以编辑配置文件后再复制）

```caddyfile /etc/caddy/Caddyfile https://paste.to/en/clone/5de34d1fbce5a Caddyfile
mydomain.me
{
  root /var/www/mydomain.me
  tls 你的邮箱
  log /var/log/caddy.log
  proxy /ray localhost:10000 {
    websocket
    header_upstream -Origin
  }
}
```

重启caddy服务器

```sh
sudo systemctl restart caddy
```

## 配置v2ray conf

修改`/etc/v2ray/config.json`文件内容：

```json /etc/v2ray/config.json https://paste.to/en/clone/5de35ac9c897b config.json
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

# 完事

## 客户端配置

```json /etc/v2ray/config.json https://paste.to/en/clone/5de35b2f78656 config.json
{
  "inbounds": [
    {
      "port": 1080,
      "listen": "127.0.0.1",
      "protocol": "socks",
      "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls"]
      },
      "settings": {
        "auth": "noauth",
        "udp": false
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "vmess",
      "settings": {
        "vnext": [
          {
            "address": "mydomain.me",
            "port": 443,
            "users": [
              {
                "id": "b831381d-6324-4d53-ad4f-8cda48b30811",
                "alterId": 64
              }
            ]
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "wsSettings": {
          "path": "/ray"
        }
      }
    }
  ]
}
```

> 参考：
 https://github.com/caddyserver/caddy/tree/master/dist/init/linux-systemd
 https://guide.v2fly.org/advanced/wss_and_web.html

{% note default %}
#### Note:另一种伪装的方式
 ```json
 "transport": {
   "quicSettings": {
     "security": "none",
     "key": "",
     "header": {
     "type": "wechat-video"
   }
 }
 ```
{% endnote %}