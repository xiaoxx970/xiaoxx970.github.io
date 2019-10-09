---
title: Coding绑定ssh并部署hexo
date: 2018-10-18 20:51:09
tags: note
---
通过ssh连接git需要配置公钥，先在本地生成公钥

```bash
ssh-keygen -t rsa -C "your_email@example.com"
```

生成在目录`~/.ssh`下面，`.ssh/id_rsa.pub`就是公钥，绑定coding的时候在设置里点添加公钥，然后复制`.pub`文件里的内容过去，<!--more-->保存后还需要认证一下：

```bash
ssh -T git@git.coding.NET
```

按照提示输`yes`
coding会提示绑定成功

```powershell
PS D:\Onedrive\文档\hexo> ssh -T git@git.coding.NET
The authenticity of host 'git.coding.net (118.25.***.124)' can't be established.
RSA key fingerprint is SHA256:jok3FH7q5LJ6qvE7iPNehBgXRw51ErE77S0Dn+Vg/Ik.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'git.coding.net,118.25.***.124' (RSA) to the list of known hosts.
Coding 提示: Hello xiaoxx97, You've connected to Coding.net via SSH. This is a personal key.
xiaoxx97，你好，你已经通过 SSH 协议认证 Coding.net 服务，这是一个个人公钥
```

以及，如果你的项目的名称不是`你的用户名.coding.me`，虽然也可以开启静态页面，但是图片的路径会出错，导致所有图片显示不出来，要解决这个问题，绑定一个域名就好了。

关于hexo的配置文件的deploy部分
```yml
deploy:
  type: git
  repo:
    coding: git@git.coding.net:你的用户名/项目名.git,master
```
`.git`后面`,master`要记得加
还有现在coding好像在改版，项目页面复制下来的git链接域名是`git.dev.tencent.com`，而根据我现在的实践操作发现如果我不把域名换成`git.coding.net`的话是没法部署成功的，失败原因是`Host key verification failed.`

如果没装过deployer要先装不然会deploy失败

```bash
npm install hexo-deployer-git --save
```