title: 常用操作
date: 2015-08-05 18:42:15
categories: Linux
toc: true
---
## 使用wget命令模拟post请求
Linux中的`wget`是一个非常强大的命令，常用来下载文件。参考:[wget 命令用法详解](http://www.cnblogs.com/analyzer/archive/2010/05/04/1727438.html).也可以用来模拟post请求:
```bash
1. 简单页面的抓取  
wget http://domain.com/path/simple_page.html  
2. 添加自己的head  
wget --header="MyHeader: head_value" http://domain.com/path/page/need_header.php  
3. 伪装成浏览器  
有些网站，例如facebook，会检测请求方式是否是浏览器，如果不是正常的浏览器，那么会redirect到一个"incompatible browser"的错误页面。
这时候需要wget伪装成一个浏览器（我是Mozilla Firefox！）：  
wget --user-agent="Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 (.NET CLR 3.5.30729)" 
	http://domain.com/path/page/check_user_agent.php  
4. post数据到某个页面  
wget不光可以用get方式请求网页，还可以post data的，那样就可以实现自动注册、自动登录了（有验证码的页面除外。。。。）  
wget --post-data="user=user1&pass=pass1&submit=Login" http://domain.com/login.php  
5. 访问需要登录的页面  
有些页面的访问需要登录，访问的时候需要传递cookie，这时候就需要和上面提到的post方式结合。一般过程是：post用户名和密码登录、保存cookie，
然后访问页面时附带上cookie。  
wget --post-data="user=user1&pass=pass1&submit=Login" --save-cookies=cookie.txt --keep-session-cookies http://domain.com/login.php  
wget --load-cookies=cookie.txt http://domain.com/path/page_need_login.php  
```

## 添加用户
在搭建hadoop或者storm等集群时，最好单独创建用户来操作:
```bash
1.添加帐号
useradd -m -s /bin/bash -g groupname username
-c comment 指定一段注释性描述。
-d 目录 指定用户主目录，如果此目录不存在，则同时使用-m选项，可以创建主目录。
-g 用户组 指定用户所属的用户组。
-G 用户组，用户组 指定用户所属的附加组。
-s Shell文件 指定用户的登录Shell。(/bin/bash 使用bash（ 默认为 /bin/sh 使用默认不会在 $ 符前面出现loginname@ubuntu）)
-u 用户号 指定用户的用户号，如果同时有-o选项，则可以重复使用其他用户的标识号。
-m 创建home目录 （不加这个要手动添加目录，不然会出现No directory,Logging in with HOME=/ ）

接着修改新用户密码: passwd username

2.删除帐号
userdel -r username
-r，它的作用是把用户的主目录一起删除。

3.添加用户组
groupadd groupname
-g GID 指定新用户组的组标识号（GID）。
-o 一般与-g选项同时使用，表示新用户组的GID可以与系统已有用户组的GID相同。

4.使username用户可以执行sudo命令
有时新用户执行sudo命令时会出现如下提示:
"Sorry, user username is not allowed to execute '/usr/bin/vim /etc/sudoers' as root on jassassin."

解决方式:
su -  //切换至root用户
vim /etc/sudoers //添加
	root    ALL=(ALL:ALL) ALL

	username   ALL=(ALL:ALL) ALL

wq!  //保存

5.对于jdk等环境变量，在~/.profile中修改
```

## 添加自起服务
工作中实际项目经常是被部署到Linux服务器上进行运行的。在此情况下编写一个项目启动停止脚本会使项目管理起来更为方面。如果再进一步将其做成linux系统服务，那就更加方便了。因为这样就不用再去项目目录下去执行管理脚本。同时也可以将此服务做成开机启动项！
1. 编写管理脚本,如myserviced
```bash
#!/bin/sh  
#chkconfig: 2345 80 05   
#description: myservice   

# 接收输入参数start/stop/restart
case $1 in  
start)  
    echo "myservice startup" #将该行替换成你自己的服务启动命令  
    ;;  
stop)  
    echo "myservice stop" #将该行替换成你自己服务的启动命令  
    ;;  
restart)  
    echo "myservice stop" #...  
    echo "myservice startup" #...  
    ;;  
*)  
    ;;  
esac  

# chkconfig 2345表示服务的运行级别，80代表Start的顺序，05代表Kill（Stop）的顺序；
```
2. 将编写的脚本放到/etc/init.d/，将myserviced的访问权限加上“可执行"权限
```bash
$ chmod +x /etc/init.d/myserviced
```

3. 添加服务
```bash
$ chkconfig --add myserviced  
# 查看是否添加成功
$ chkconfig --list | grep myserviced
```

4. 如果需要开机启动
```bash
# 单独开启myserviced服务的命令
$ chkconfig myserviced on
# 单独关闭myserviced服务的命令
$ chkconfig myserviced off
# 查看服务状态
$ /etc/init.d/myserviced status
```
以上步骤完成之后，重启!

## 查看端口被哪个进程占用
```bash
$ netstat -ntlp|grep 4000 #查询的端口
# 输出
tcp        0      0 0.0.0.0:4000            0.0.0.0:*               LISTEN      6689/hexo  # 6689即占用4000端口的进程号
$ ps -ef|grep 6689 # 查看该进程的信息
# 输出 14:00该进程启动时间
eagle     6689  6675  0 14:00 pts/7    00:00:06 hexo # 这个就是进程信息了                                         
```
将以上的过程进行合并
```bash
$ netstat -ntlp|grep 4000|awk '{print $7}'
```

## find 指定文件
```bash
# . 当前目录   -maxdepth 默认只查询当前目录,不查询子目录,通过该参数可以设置查询的子目录最大深度  
find . -maxdepth 10 -name "124-*"
```

## find 文件内容
```bash
# . 当前目录   -maxdepth 默认只查询当前目录,不查询子目录,通过该参数可以设置查询的子目录最大深度  dsymbolized 查询关键字
find . -maxdepth 10 -type f -name "*.log" | xargs grep "dsymbolized"
```

## 查询文件或文件夹的磁盘使用空间
```bash
[root@centos6 /]# du -h --max-depth=10 /opt/*
76K	/opt/kafka_2.10-0.8.2.0/bin/windows
156K	/opt/kafka_2.10-0.8.2.0/bin
18M	/opt/kafka_2.10-0.8.2.0/libs
44K	/opt/kafka_2.10-0.8.2.0/config
8.8G	/opt/kafka_2.10-0.8.2.0/logs
8.9G	/opt/kafka_2.10-0.8.2.0
16M	/opt/kafka_2.10-0.8.2.0.tgz
4.0K	/opt/rh
8.0K	/opt/server-cluster.properties
4.0K	/opt/zk/data
8.0K	/opt/zk
16K	/opt/zookeeper/data/version-2
28K	/opt/zookeeper/data
28K	/opt/zookeeper/logs/version-2
32K	/opt/zookeeper/logs
64K	/opt/zookeeper

```

## 统计当前目录大小并按大小排序
```bash
[root@centos6 /]# du -sm * | sort -n
0	selinux
0	sys
1	dev
1	home
1	kafka_metrics
1	logs
1	lost+found
1	media
1	mnt
1	srv
2	sbt
2	sbt-0.13.9.tgz
8	bin
15	sbin
17	kafka_2.9.1-0.8.2.1.tgz
19	kafka
22	lib64
27	etc
28	boot
42	zookeeper
82	root
106	var
148	lib
1613	usr
2411	tmp
9040	opt

```

## 统计多个文件占用的磁盘情况

```bash
$ du -ch LICENSE pom.xml
28K	LICENSE
44K	pom.xml
72K	total
```

## 找出指定目录中最大的10个文件

* 统计当前目录下所有文件和目录，输出最大的十个文件或目录

```bash
# du -a:指定所有目录和文件 -k:KB
# sort -n:按数字排 -r:倒序 -k:按第n列排序 
$ du -ak ./* | sort -nrk 1 | head
10128	./flume-ng-sinks
6488	./flume-ng-sinks/flume-ng-morphline-solr-sink
5056	./flume-ng-core
4284	./flume-ng-channels
3236	./flume-ng-sinks/flume-ng-morphline-solr-sink/target
3212	./flume-ng-sinks/flume-ng-morphline-solr-sink/src
3132	./flume-ng-sinks/flume-ng-morphline-solr-sink/target/test-classes
3124	./flume-ng-sinks/flume-ng-morphline-solr-sink/src/test
3088	./flume-ng-core/target
3032	./flume-ng-sinks/flume-ng-morphline-solr-sink/src/test/resources
```

* 统计当前目录下所有文件，输出最大的十个文件

```bash
$ find . -type f  -exec du -h {} \; |sort -nrk 1 | head
848K	./.git/objects/pack/pack-ccf6f43619f071abfc08a7c2068afda5b692506e.idx
352K	./flume-ng-core/target/flume-ng-core-1.6.0.jar
292K	./flume-ng-channels/flume-file-channel/target/flume-file-channel-1.6.0.jar
272K	./flume-ng-channels/flume-file-channel/src/main/java/org/apache/flume/channel/file/proto/ProtosFactory.java
244K	./flume-ng-sinks/flume-ng-morphline-solr-sink/target/test-classes/test-documents/sample-statuses-20120906-141433-medium.avro
244K	./flume-ng-sinks/flume-ng-morphline-solr-sink/src/test/resources/test-documents/sample-statuses-20120906-141433-medium.avro
220K	./flume-ng-sinks/flume-ng-morphline-solr-sink/target/test-classes/test-documents/testKeynote.key
220K	./flume-ng-sinks/flume-ng-morphline-solr-sink/src/test/resources/test-documents/testKeynote.key
216K	./flume-ng-doc/sphinx/FlumeUserGuide.rst
164K	./flume-ng-sinks/flume-ng-morphline-solr-sink/target/test-classes/test-documents/testPPT_various.ppt
```
