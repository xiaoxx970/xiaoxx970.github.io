---
title: 小米6刷入miui欧洲版以及安装小米钱包、应用商店APP
date: 2018-12-18 16:03:11
tags: MIUI
---
> [miui.eu](miui.eu)，一个真正没有广告的系统，比国际版还要纯净
> 我一开始照着知乎[这个教程](https://www.zhihu.com/question/50231539)刷的，刷了后死活开不了机，也就是卡在了MI界面，后来在miui欧洲论坛找到了[这个](https://xiaomi.eu/community/threads/bootloop-problem-while-flashing-eu-stable.46593/)答案，完全符合我的情况，不能直接从国内版刷成欧洲版，要先刷个国际版，在国际版的基础上才能刷欧洲版。

> miui欧洲版自带人脸解锁，抬起亮屏，还有谷歌的Smart Lock，挺有意思。

<!--more-->
首先要说的是，要折腾，先备份。
如果你用了谷歌验证器，可以象我一样换成Authy，通过手机登录，不用担心换手机找不回来
微信可以通过Windows端备份聊天记录
相册短信便签什么的就交给小米云，差不多就这些

下面大概列一下操作顺序以及网站，细节方面的步骤，是很容易找到的，我如果有空会再列。

1. 没解锁的要先解锁
    http://www.miui.com/unlock/index.html

2. 刷入国际版ROM
去下载线刷包：[线刷包地址](http://en.miui.com/download.html)
手机音量下+电源键开机，进入Fastboot模式
线刷教程可以去看国内的miui：http://www.miui.com/shuaji-393.html

2. 不用开机，继续刷入twrp
[twrp官方下载](https://twrp.me/Devices/)

3. 进入twrp，刷eu固件
[格式化data分区](#last)（如果你想开启全盘默认加密，请不要开机，直接看第五步）
去下载miui欧洲版：[miui欧洲版发布页面](https://xiaomi.eu/community/link-forums/roms-download.73/)
连接电脑，进入twrp后应该是能在电脑上看到手机，不能的话在设置里找开启MTP
从电脑把eu固件拖入手机存储，从twrp中选择固件刷机

4. 重启开机，进入系统
到这里已经完成miui欧洲版刷机了，选择语言，连WiFi，登账号
![](screen1.jpg)开机后的桌面
miui欧洲版阉割了很多比如小米钱包，里面的卡模拟的功能我用得到，包括公交卡什么的，所以装好后我又去折腾如何装回这个应用

1. 欧洲版固件安装MiPay和小米商店
很麻烦，不能直接通过APK安装，要从中国版固件的system.img里面提取软件包，还要通过Root权限把软件包写入System分区，这里有一个教程：[MIUI国际版mi pay解决方案](https://www.yipkwong.com/2018/06/06/167/)，里面叙述了详细经过
但是！
但是我没用这个方法，虽然尝试过但是卡在了挂载镜像那一步，后来我从另一个地方找到了方便的方法：[Mi Pay Extractor](https://github.com/linusyang92/mipay-extract)，是一个提取脚本，可以把上面那个教程里的步骤自动实现
直接`git clone`到本地以后把miui国内版卡刷包放在同一目录下
![目录截图](git-clone.jpg)然后要在同一目录放入**国内的**miui**卡刷包**（和miui欧洲版卡刷包，如果你要开启[全盘加密](#last)）
就可以运行`extract.bat`，如果出现下面这样的错误
    ```bash
    extract.sh: line 2: $'\r': command not found
    extract.sh: line 3: cd: $'.\r': No such file or directory
    extract.sh: line 4: $'\r': command not found
    extract.sh: line 6: $'\r': command not found
    extract.sh: line 18: $'\r': command not found
    extract.sh: line 19: syntax error near unexpected token `$'{\r''
    'xtract.sh: line 19: `exists() {
    请按任意键继续. . .
    ```
    那就是因为`extract.sh`文件用的换行符不对，把原来的换行符`CRLF`改成`LF`后保存就可以正常运行了
    Windows下双击`extract.bat`就可以开始提取，会要几分钟时间
    ![bat-run](bat-run.jpg)这样就说明提取成功了，在目录下会找到`mipay-MIxxx.zip`,这就是一个卡刷包，通过twrp可以直接刷入
    <a id="five"/>
    
    按照readme里的说明，还可以运行`cleaner-fix.sh`来生成修复日历和天气的刷机包，具体说就是让日历显示农历，天气app换回国内的。这个命令同时还会生成开启默认加密的刷机包。
    对于想在负一屏还能用微信支付宝扫码快捷键的，`extract.bat --appvault`可以生成这样的修复包，也就是替换成跟国内一样的信息助手
    Finally，我们有了四个准备卡刷的包：（第二个force-fbe是[文末](#last)提到的开启全盘加密）
    ![目录截图2](mipay-extract.jpg)~~全扔进手机，一个一个刷就是了~~  先别放到手机看我说完
    然而，问题没那么简单
    我遇到的是一个叫255的错误，简单来说就是以上这四个包，没一个能刷成功的，网上搜255错误，原因很多，没有一个能解决我的问题的，于是我慢慢想起了前面提到的`CRLF`，说不定又是这个东西在捣鬼。打开zip包，第一个文件夹`META-INF`一路点进去，最后看到了一个叫做`update-binary`的文件，这个文件类似于脚本，在刷机的时候执行的，和其他能刷成功的一对比发现确实是因为用了`CRLF`换行符导致错误的。用VScode打开转换后保存，更新压缩包，这次就没有任何毛病了,在twrp下开启MTP把刷机包存到手机，可以全部成功刷入。
    > 在[release页面](https://github.com/linusyang92/mipay-extract/releases)有他提取好的卡刷包，虽然是Mix2的但是发现也适用于我的小米6，如果你是米6或mix2不想折腾也可以用作者提取好的
    
    下面是安装小米应用商店，装了就可以用它来更新小米钱包，而不用每次想更新都去下载线刷包。
    这个可以直接通过APK安装，我是在刷完小米钱包后下载应用商店APK安装的，不知道顺序能不能反过来。
    下载地址：https://xiaomi-market.cn.uptodown.com/android
    不知道为什么这个网站是被墙了的，开全局去下
    然后就可以安装了，一切都非常完美，可以一键装应用和更新
<a id="last" />

最后，有几个教程提到过，关于支付安全，miui欧洲版没有默认启用全盘加密（FBE），最直接的影响就是进入恢复模式不用解密，数据暴露在捡到你手机的人面前，所以我还去手动开了全盘加密，~~在设置→安全→加密和凭据里面，可以手动开启加密，要的时间比较长，在充电的时候操作。~~脚本作者的说法是在格式化data分区后刷入国际版固件，然后再刷入`force-fbe`刷机包，就可以开启miui的默认加密![](screen.png)开机后设置的图形密码，会在以后进去twrp的时候也要输入图形密码，否则无法操作你的数据。详细请看[这里](https://github.com/linusyang92/mipay-extract#optional-encryption-for-xiaomieu-roms)