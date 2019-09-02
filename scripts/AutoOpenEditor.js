let spawn = require('hexo-util/lib/spawn');

hexo.on('new', (data) => {
  spawn('C:/\Program Files/\Typora/\Typora.exe', [data.path]);
});