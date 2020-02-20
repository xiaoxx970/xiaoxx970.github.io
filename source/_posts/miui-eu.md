title: 小米6刷入miui欧洲版以及安装小米钱包、应用商店APP,开启全盘加密
tags:

  - MIUI
date: 2018-12-18 16:03:00
---
{% note info no-icon %}
[miui.eu](https://xiaomi.eu/community/forums/miui-rom-releases.103/)，一个真正没有广告的系统，比国际版还要纯净
{% endnote %}

我一开始照着知乎[这个教程](https://www.zhihu.com/question/50231539)刷的，刷了后死活开不了机，也就是卡在了MI界面，后来在miui欧洲论坛找到了[这个](https://xiaomi.eu/community/threads/bootloop-problem-while-flashing-eu-stable.46593/)答案，完全符合我的情况，不能直接从国内版刷成欧洲版，要先刷个国际版，在国际版的基础上才能刷欧洲版。

> miui欧洲版自带人脸解锁，抬起亮屏，还有谷歌的Smart Lock，挺有意思。

<!--more-->

----

> 2020-02-20 更新:
> 
> 不再跟随官方miui的链接, 因为官方已经不再更新开发板的链接, 找了一个第三方列表: [小米6 MIUI开发版下载索引 (卡刷包)](https://miuiver.com/sagit_developer_recovery/). 现在还是每周自动生成一次, 发布在这里👉[releases 页面](https://github.com/xiaoxx970/mipay-extract/releases), 要注意自从9.8.15后面的版本我都没有自己测试过, 出了问题开机卡米什么的一般清data可以解决.

> 2019-08-18 更新：
>
> 现在已经半夜1点，我的小米6正在通过线刷刷国内版miui，起因是这次更新miui9.8.15版本后出了一点问题怎么也开不了机，具体的问题应该就是换行符的问题，我刚通过脚本自动获取链接的方式做到持续集成，可以全自动生成刷机包而不用每次改两个链接以及git commit,tag,push等，现在只要在持续集成那边开个定时，就可以每周自动出炉修复刷机包并且上传到GitHub的release页面，可惜我再也用不到了（大概），还需要的朋友记得在评论区告诉我，我会考虑加上其他机型或者出个持续集成的教程。
>
> 链接在这里：https://github.com/xiaoxx970/mipay-extract/releases
>
> 现在已经开启了每周更新，不用我动就会保持最新版本的，用着miui欧洲版的同学每次更新前去这个页面下载一下就可以刷机了。 

首先要说的是，要折腾，先备份。
如果你用了谷歌验证器，可以象我一样换成Authy，通过手机登录，不用担心换手机找不回来
微信可以通过Windows端备份聊天记录
相册短信便签什么的就交给小米云，差不多就这些

其次要说的是，等下用到的所有提取出来的刷机包，在每一次更新系统后都会失效，你可以选择再次刷入。
特别地，关于支付安全，eu固件默认关闭了全盘强制加密（FBE）功能，这跟国内固件不一样，最直接的影响就是进入恢复模式不用解密，数据暴露在捡到你手机的人面前，所以我是选择刷入了开启加密的补丁包，同样的每一次更新系统就必须在更新后重新刷入`force-fbe`包，否则无法开机。

# 请选择你的选择↓

{% tabs fbe %}
<!-- tab 开启全盘加密 -->

下面从第一步，你还是个国内miui系统开始

# 解锁bootloader

看这里👉 http://www.miui.com/unlock/index.html

# 刷入国际版ROM

{% note info %}
根据评论，可以直接刷欧洲版，只要刷完欧洲版，清理一下缓存就行了，所以这步可跳过试试
{% endnote%}

欧洲版和国内版系统分区不一样（我猜的），直接卡刷欧洲版我试过没法开机（可能还是因为FBE的缘故？），反正为了保证成功就先刷国际版ROM，顺便把系统和数据也清了
   - 去下载线刷包：[线刷包地址](http://en.miui.com/download.html)
   - 手机音量下+电源键开机，进入Fastboot模式
   - 下载小米的[通用刷机工具](http://bigota.d.miui.com/tools/MiFlash2018-5-28-0.zip)
   - 按照教程一步一步往下做
   - **注意**软件打开右下角不要选`全部删除并lock`，选择`全部删除`就可以了
   - 线刷具体教程：http://www.miui.com/shuaji-393.html

# 不用开机，继续刷入twrp
怎么做到的呢，就是线刷软件提示刷入成功，手机重启的时候，还是按住音量下+电源键开机，进入Fastboot模式，通过ADB(刚才下载的通用刷机工具里有)终端命令来刷入。
如果还是不小心开机了没关系，等下刷系统的时候在twrp里面双清一下就可以了。
1. [twrp官方下载](https://twrp.me/Devices/)

    选择你的机型对应下载下来

2. 打开adb终端

    adb终端的位置在`\MiFlash2018-5-28-0\Source\ThirdParty\Google\Android`里面，进入到`Android`文件夹，鼠标在空白的地方按住Shift以后右键，选择在此处打开cmd/power shell窗口，就可以使用adb了。

3. 终端输入命令

    ```bash
    fastboot flash recovery twrp.img
    fastboot boot twrp.img
    ```
    `twrp.img` 是替换成你的twrp包的路径和名称。
   
   > 第二条命令执行完后手机就会自己重启到twrp界面，可以设置成中文。

# 进入twrp，刷eu固件
1. 去下载miui欧洲版：[miui欧洲版发布页面](https://xiaomi.eu/community/link-forums/roms-download.73/)

2. 格式化data分区

3. 连接电脑，把eu固件拷入sdcard目录
   
   手机在twrp界面，电脑上应该能看到手机，不能的话在手机点挂载，然后点开启MTP
   
4. 选择eu包刷机

   {% note primary %}因为你选了要开启全盘加密

   刷到这里的时候手机先放一边, 刷完不要开机, 下面操作电脑弄出修复包一起刷了以后再开机

   {% endnote %}

# 提取加密包以及mipay
> 要从中国版固件的system.img里面提取软件包，还要通过Root权限把软件包写入System分区，这里有一个教程：[MIUI国际版mi pay解决方案](https://www.yipkwong.com/2018/06/06/167/)，里面叙述了详细经过，但是我没用这个方法，虽然尝试过但是卡在了挂载镜像那一步。

使用：[Mi Pay Extractor](https://github.com/linusyang92/mipay-extract)，是一个提取脚本，可以自动提取出卡刷包中的MiPay软件和日历、天气等。
1. 下载zip包: [repo的下载链接](https://github.com/linusyang92/mipay-extract/archive/master.zip)

   linux用户可以clone
   
    ```bash
    git clone https://github.com/linusyang92/mipay-extract.git
    ```

2. 下载国内的miui最新卡刷包，放入同一目录

2. miui欧洲版卡刷包，也放在同一目录

   ![目录截图](https://xiaoxx.oss-cn-beijing.aliyuncs.com/blog-img/miui-eu/git-clone.jpg)

4. 运行`extract.bat`(双击)

   会生成一个卡刷包`mipay-MIxxx.zip`

   {% note default %}

   如果出现下面这样的错误：

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

   {% endnote %}

   Windows下双击`extract.bat`就可以开始提取，会要几分钟时间。
   ![bat-run](https://xiaoxx.oss-cn-beijing.aliyuncs.com/blog-img/miui-eu/bat-run.jpg)这样就说明提取成功，现在目录下会有`mipay-MIxxx.zip`,这就是一个卡刷包，通过twrp可以直接刷入

5. 运行`cleaner-fix.bat`(双击)

    {% note primary %}

    这里就是生成开启默认加密的刷机包 `force-fbe`
    {% endnote %}

    还可以生成修复日历和天气的刷机包，具体说就是让日历显示农历，天气app换回国内的。

6. 对于想在负一屏还能用微信支付宝扫码快捷键的，以及查快递，在cmd运行`extract.bat --appvault`可以生成这样的修复包，也就是替换成跟国内一样的信息助手

Finally，我们有了四个准备卡刷的包：
![目录截图2](https://xiaoxx.oss-cn-beijing.aliyuncs.com/blog-img/miui-eu/mipay-extract.jpg)全部还是通过MTP放进手机，一个一个刷就是了

{% note warning %}如果刷机的时候遇到255错误

简单来说就是以上这四个包，没一个能刷成功的，网上搜255错误，原因很多，没有一个能解决我的问题的，于是我慢慢想起了前面提到的`CRLF`，说不定又是这个东西在捣鬼。打开zip包，第一个文件夹`META-INF`一路点进去，最后看到了一个叫做`update-binary`的文件，这个文件类似于脚本，在刷机的时候执行的，和其他能刷成功的一对比发现确实是因为用了`CRLF`换行符导致错误的。用VScode打开转换成`LF`后保存，更新压缩包，这次就没有任何毛病了,在twrp下开启MTP把刷机包存到手机，可以全部成功刷入。

{% endnote %}

# 完成, 开机

刷好后就可以开机

选择语言，连WiFi，登账号
![](https://xiaoxx.oss-cn-beijing.aliyuncs.com/blog-img/miui-eu/screen1.jpg)

这时候如果进设置就会看到手机已加密

> 是用来看的, 要是看到没加密不能在这里选开启加密, 不然会出问题
>
> (如果有人试了不刷加密包来到这里可以开启加密记得告诉我)

![](https://xiaoxx.oss-cn-beijing.aliyuncs.com/blog-img/miui-eu/screen.png)

好了这样就完事了, 可以继续看下面, 下个国产的应用商店

<!-- endtab -->

<!-- tab 不开启全盘加密 -->

下面从第一步，你还是个国内miui系统开始

# 解锁bootloader

看这里👉 http://www.miui.com/unlock/index.html

# 刷入国际版ROM

（根据评论，可以直接刷欧洲版，只要刷完欧洲版，清理一下缓存就行了，所以这步可跳过）

欧洲版和国内版系统分区不一样（我猜的），直接卡刷欧洲版我试过没法开机（可能还是因为FBE的缘故？），反正为了保证成功就先刷国际版ROM，顺便把系统和数据也清了

   - 去下载线刷包：[线刷包地址](http://en.miui.com/download.html)
   - 手机音量下+电源键开机，进入Fastboot模式
   - 下载小米的[通用刷机工具](http://bigota.d.miui.com/tools/MiFlash2018-5-28-0.zip)
   - 按照教程一步一步往下做
   - **注意**软件打开右下角不要选`全部删除并lock`，选择`全部删除`就可以了
   - 线刷具体教程：http://www.miui.com/shuaji-393.html

# 不用开机，继续刷入twrp

怎么做到的呢，就是线刷软件提示刷入成功，手机重启的时候，还是按住音量下+电源键开机，进入Fastboot模式，通过ADB(刚才下载的通用刷机工具里有)终端命令来刷入。
如果还是不小心开机了没关系，等下刷系统的时候在twrp里面双清一下就可以了。

1. [twrp官方下载](https://twrp.me/Devices/)

    选择你的机型对应下载下来

2. 打开adb终端

    adb终端的位置在`\MiFlash2018-5-28-0\Source\ThirdParty\Google\Android`里面，进入到`Android`文件夹，鼠标在空白的地方按住Shift以后右键，选择在此处打开cmd/power shell窗口，就可以使用adb了。

3. 终端输入命令

    ```bash
    fastboot flash recovery twrp.img
    fastboot boot twrp.img
    ```
    
    `twrp.img` 是替换成你的twrp包的路径和名称。

    > 第二条命令执行完后手机就会自己重启到twrp界面，可以设置成中文。

# 进入twrp，刷eu固件

1. 去下载miui欧洲版：[miui欧洲版发布页面](https://xiaomi.eu/community/link-forums/roms-download.73/)
3. 连接电脑，把eu固件拷入sdcard目录
   手机在twrp界面，电脑上应该能看到手机，不能的话在手机点挂载，然后点开启MTP

3. 从手机上点刷机，选择刷机包，完成，开机。

到这里已经完成miui欧洲版刷机了，选择语言，连WiFi，登账号
![](https://xiaoxx.oss-cn-beijing.aliyuncs.com/blog-img/miui-eu/screen1.jpg)这是开机后的桌面
miui欧洲版阉割了很多比如小米钱包，里面的卡模拟的功能我用得到，包括公交卡什么的，所以接下来折腾如何装回这个应用

# 提取Mipay安装包以及本土化修复包

> 要从中国版固件的system.img里面提取软件包，还要通过Root权限把软件包写入System分区，这里有一个教程：[MIUI国际版mi pay解决方案](https://www.yipkwong.com/2018/06/06/167/)，里面叙述了详细经过，但是我没用这个方法，虽然尝试过但是卡在了挂载镜像那一步。

使用：[Mi Pay Extractor](https://github.com/linusyang92/mipay-extract)，是一个提取脚本，可以自动提取出卡刷包中的MiPay软件和日历、天气等。

1. 下载zip包: [repo的下载链接](https://github.com/linusyang92/mipay-extract/archive/master.zip)

   linux用户可以clone

    ```bash
    git clone https://github.com/linusyang92/mipay-extract.git
    ```


2. 下载国内的miui最新卡刷包，放入同一目录

3. miui欧洲版卡刷包，也放在同一目录

   ![目录截图](https://xiaoxx.oss-cn-beijing.aliyuncs.com/blog-img/miui-eu/git-clone.jpg)

4. 运行`extract.bat`(双击)

   可以生成加密包和一个修复包

   {% note default %}

   如果出现下面这样的错误：

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

   {% endnote %}   

   ![bat-run](https://xiaoxx.oss-cn-beijing.aliyuncs.com/blog-img/miui-eu/bat-run.jpg)

   这样就说明提取成功，现在目录下会有`mipay-MIxxx.zip`,这就是一个卡刷包，通过twrp可以直接刷入

5. 运行`cleaner-fix.bat`
   生成修复日历和天气的刷机包，具体说就是让日历显示农历，天气app换回国内的。这个命令同时还会生成开启默认加密的刷机包。
   
6. 对于想在负一屏还能用微信支付宝扫码快捷键的，以及查快递，`extract.bat --appvault`可以生成这样的修复包，也就是替换成跟国内一样的信息助手

Finally，我们有了四个准备卡刷的包：
![目录截图2](https://xiaoxx.oss-cn-beijing.aliyuncs.com/blog-img/miui-eu/mipay-extract.jpg)全扔进手机，一个一个刷就是了

{% note warning %}如果刷机的时候遇到255错误

简单来说就是以上这四个包，没一个能刷成功的，网上搜255错误，原因很多，没有一个能解决我的问题的，于是我慢慢想起了前面提到的`CRLF`，说不定又是这个东西在捣鬼。打开zip包，第一个文件夹`META-INF`一路点进去，最后看到了一个叫做`update-binary`的文件，这个文件类似于脚本，在刷机的时候执行的，和其他能刷成功的一对比发现确实是因为用了`CRLF`换行符导致错误的。用VScode打开转换成`LF`后保存，更新压缩包，这次就没有任何毛病了,在twrp下开启MTP把刷机包存到手机，可以全部成功刷入。

{% endnote %}

<!-- endtab -->
{% endtabs %}

下面是安装小米应用商店，装了就可以用它来更新小米钱包，而不用每次想更新都去下载线刷包。

下载地址：https://xiaomi-market.cn.uptodown.com/android

不知道为什么这个网站是被墙了的，开全局去下

然后就可以安装了，一切都非常完美，可以一键装应用和更新

最后，终于写完了这个教程，自我感觉是很详细了，希望可以帮到跟我一样在折腾miui的人。我刷这个系统的初衷是国内版变得越来越难用，最主要的表现是经常熄屏自己莫名震动，还经常自己亮屏，打开了看也没有什么通知，后来上网一搜发现我不是一个人，这是小米系统本身的问题，那些震动是真的有通知不过之前被我从通知栏禁止了，可能禁止的层面不对，等通知到达了震动了系统才把通知删掉，这不是折磨人么。我就找能不能刷类似CM的原版安卓，然后就在知乎上看到了miui欧洲版，感觉对安卓的底层不会改太多，就折腾用欧洲版来了。现在用了两个星期，确实好用，字体不好看还换了个字体，外观上和国内版差别也不大。就是每次升级系统不是很方便就是了，之后会想办法用持续集成完成自动的提取。


> 2019-4-23更新：总结一下用miui-eu时更新系统步骤
>
>    1. 下载eu包：https://sourceforge.net/projects/xiaomi-eu-multilang-miui-roms/files/xiaomi.eu/MIUI-WEEKLY-RELEASES/
>
>    2. 下载国内相同版本包：http://www.miui.com/download.html
>
>    3. 在`mipay-extract`文件夹中执行以下命令
>       ```
>       ./cleaner-fix.bat
>       ./extract.bat --appvault
>       ```
>
>    4. 生成的4个包加上下载下来的eu包拷贝进手机，重启进入twrp选择刷机包刷机
>
>       可以批量选择刷机包，顺序是eu包在最前面，其他的在后面刷。
>
>       > 我的[Release页面](https://github.com/xiaoxx970/mipay-extract/releases) ，如果你也是小米6就可以直接下载下来用