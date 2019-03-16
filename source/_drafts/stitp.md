---
title: 项目结构
date: 2018-11-29 13:35:52
tags:
---
Laravel 的 `Hash` 类提供了安全的 Bcrypt 哈希演算法：
对密码加密
```php
$password = Hash::make('secret');
```
验证密码
```php
if (Hash::check('secret', $hashedPassword))
{
    // The passwords match...
}
```
确认密码是否需要重新加密
```php
if (Hash::needsRehash($hashed))
{
    $hashed = Hash::make('secret');
}
```
使用 Auth::attempt 方法来验证用户成功登录之前的信息确认：
```php
if (Auth::attempt(array('email' => $email, 'password' => $password)))
{
    return Redirect::intended('dashboard');
}
```
判定一个用户是否已经登入，使用 check 这个方法：
```php
if (Auth::check())
{
    // The user is logged in...
}
```

`app` 目录里面包含了 `views`（视图）,  `controllers`（控制器）, 还有 `models`（模组） 等目录，其中`http/routes.php`这个文件起到了中枢引导的作用，所有域名后的路径都交由这个文件跳转到对应的控制器类

控制页面样式的`style.css`位于`\public\theme\default\pc\css`中

控制主页内容的文件`index.blade.php`位于`\resources\views\theme\default\pc\`中，当然，基于手机我们还用了另外的内容和样式以适应小屏幕显示信息。


后台：`admin panel` 
or:
编辑活动说明用的编辑器：
`edui-editor`（富文本编辑器）
所有日期选择的部分我们使用了
`ivu-date-picker`，一个非常美观的日期选择组件