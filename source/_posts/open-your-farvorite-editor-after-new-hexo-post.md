---
title: hexo new后自动打开你喜爱的编辑器
date: 2019-09-02 15:16:44
tags: hexo_tricks
---

> 作为一个用hexo写博客的bloger，每次写文章都是件麻烦事：对我来说，要先用Code打开Hexo工作区，然后`Ctrl+``打开终端先pull一下，再开始`hexo new post something`，接下来去目录找到_posts，点进去打开刚创建的md，然后，才开始写文章。

这篇post就是解决众多繁杂步骤中的一环：找md文件然后打开的过程。

<!---more---->

很简单，要做的就是写个脚本让`NodeJS`知道我什么时候新建了post，然后脚本帮我打开刚新建好的post.md，最主要的是，可以用自己喜爱的编辑器，比如说我用的是[Typora](https://typora.io/)。

1. 在你的hexo目录下新建一个文件夹名叫`scripts`（你的hexo目录就是你执行hexo命令的目录）

	```bash
	mkdir scripts
	cd scripts
	```

2. 在`scripts`文件夹里新建一个脚本文件叫做`AutoOpenEditor.js`（也可以是其他名字），内容如下：

   ```js
   let spawn = require('hexo-util/lib/spawn');
   
   hexo.on('new', (data) => {
     spawn('C:/\Program Files/\Typora/\Typora.exe', [data.path]);
   });
   ```

   这几句话的大概意思就是，在检测到执行`hexo new`命令后，触发这个脚本，然后脚本执行`C:\Program Files\Typora\Typora.exe [文件路径]`这个命令，`spawn()`里就是要执行的命令和参数，有斜杠的话需要用转义符。

   这里我用的是Typora编辑器，你也可以让它用VScode来打开：

   ```js
   let spawn = require('hexo-util/lib/spawn');
   
   hexo.on('new', (data) => {
     spawn('code','-r',[data.path]);
   });
   ```

   这是针对在VScode里已经打开hexo目录工作区的情况，`-r`让code不打开新窗口，而是作为标签页打开。

这样就可以了，以后每次`hexo new post`，都会在新建后帮你打开编辑器，虽然只是少了一小环，但是让你写博客更有动力了不是。