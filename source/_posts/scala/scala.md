title: intro
date: 2015-08-05 21:17:16
categories: Scala
toc: true
---
**Scala**（发音为/ˈskɑːlə, ˈskeɪlə/）是一门多范式的编程语言，设计初衷是要集成面向对象编程和函数式编程的各种特性。其运行于`Java平台`（Java虚拟机），并兼容现有的Java程序。本文简单的介绍了scala的安装、命令行的使用、变量定义、操作符、函数定义、scala脚本等内容，通过本文可以对scala有个简单的认识！

## Scala解释器安装
[Scala官网](http://www.scala-lang.org/download/) | [All Versions Scala](http://www.scala-lang.org/download/all.html).下载所需版本Scala安装包,解压到指定目录之后,配置环境变量**Path**.比如对于Linux系统，你可以通过修改`~/.profile`文件，添加如下内容
```bash
export SCALA_HOME=
export PATH=$SCALA_HOME/bin:$PATH
```
最后执行`source ~/.profile`使配置生效!Path变量的配置可以参考`JDK环境变量配置`[Linux](http://blog.chinaunix.net/uid-12115233-id-3304951.html) | [Windows](http://jingyan.baidu.com/article/3c343ff70bc6ea0d377963df.html).
完成之后在`terminal`中输入`scala`,如下所示:
```java
eagle@jassassin ~ $ scala
Welcome to Scala version 2.10.4 (Java HotSpot(TM) 64-Bit Server VM, Java 1.7.0_67).
Type in expressions to have them evaluated.
Type :help for more information.

scala> 1+1
res0: Int = 2

```
注:
1. 上面的内容会被快速的转换为java字节码，然后交给JVM进行执行!同时scala并不要求每条语句后面必须要跟`;`，除非一行代码中有多条语句!
2. 对于scala解释器，你可以通过`Tab`键获取方法提示，或者通过方向键`↑`或`↓`获取历史输入

## 变量定义
Scala中的变量主要有`var`和`val`两种.`val`类似java中的`final`变量,一旦被赋值便不可再改变!Scala中鼓励使用val类型变量!
```java
// val类型变量的值不可被修改
scala> val msg = "hello java!"
msg: String = hello java!

scala> msg = "hello scala!"
<console>:8: error: reassignment to val
       msg = "hello scala!"
           ^
```
注意上面的第2行代码`msg: String = hello java!`,这里scala进行了类型推断!**为了避免混乱或者阅读方便,你可以在定义变量时同时指明变量类型**:
```java
//注意scala中变量类型在":"之后
scala> var msg : java.lang.String = "hello world"
msg: String = hello world
//简写
scala> var msg : String = "hello world"
msg: String = hello world
```
## 常用数据类型
与Java一样，Scala也有7种数值类型Byte、Char、Short、Int、Long、Float和Double，以及一个Boolean类型。Scala并不刻意区分基本类型与引用类型，你可以直接对数字执行方法。而scala编译器会自动对基本类型和引用类型进行转换，如:
```bash
//直接对1调用toString方法.
scala> 1.toString
res5: String = 1
```
注:如果方法不带有参数且不会改变方法调用者，则调用方法时可以不带`()`

## 算术和操作符重载
如下所示，scala中的算术操作符可以完成和java中一样的效果。但是，两者有本质的区别。scala中的`+`，相当于方法调用，或者说方法的名称就叫做`+`
```bash
scala> val sum = 10 + 10
sum: Int = 20
scala> val sum2 = 10.+(10)
warning: there were 1 deprecation warning(s); re-run with -deprecation for details
sum2: Double = 20.0

scala> println(sum2)
20.0
```

## 函数定义
scala中函数定义以`def`开头
```java
/**
 * max 	函数名称
 * x: Int 	参数以及类型(不可省略类型)
 *  : Int	函数返回值类型(有时可以省略)
 */
//在命令行输入时,多行代码以'|'换行
scala> def max(x: Int, y: Int): Int = {
     | if(x > y)
     |   x
     | y}
max: (x: Int, y: Int)Int

scala> max(1,2)
res0: Int = 2
```
scala在定义函数时,参数部分的类型不能省略!但是当函数没有返回值时则可以省略`): Int`括号后面的`: Int`:
```java
scala> def say(msg: String)={
     |   println(msg)
     | }
say: (msg: String)Unit

scala> say("HI")
HI

//当函数只有一行代码时,则可以写成下面的形式
scala> def say(msg: String)=println(msg)
say: (msg: String)Unit

scala> say("good")
good

```
注意上面的`say: (msg: String)Unit`中的Ｕnit.这里的`Unit`类似java中的`void`,表示函数没有返回值!

## Scala执行脚本
scala脚本的命令行参数保存在`args`scala数组中,可以通过`args(i)`访问.其中i从0开始!
新建demo.scala文件,输入如下内容:
```java
println("Hello " + args(0) + "!")
```
执行`scala demo.scala python`

## 从文件中读取数据
```java
import scala.io.Source

/**
 * @author eagle
 */
object ReadFile {
  def main(args: Array[String]): Unit = {
    if(args.length > 0){
      for(line <- Source.fromFile(args(0)).getLines()){
        println(line)
      }
    }
    else{
      Console.err.println("please input the absolute file path:")
    }
  }
}
```

注意上面第一行引入了:`scala.io.Source`这个类!
运行方式:`scala demo.scala **file path**`

-----------

参考
	[Sala编程](http://baike.baidu.com/link?url=M9MYf8oT2pFJzP82EyKwMw3idTDimX7T2o8pKkAoFAy9s7ohVht1DYRx4icB8gggZGbRCw9H352tKRh4lG2q__) Scala入门初探
