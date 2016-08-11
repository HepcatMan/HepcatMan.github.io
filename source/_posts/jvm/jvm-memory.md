title: memory
date: 2014-06-02 23:45:12
categories: JVM
toc: true
---
## 引文 ##
[Java虚拟机](http://baike.baidu.com/view/374952.htm?fr=aladdin)在执行Java程序的过程中会把它所管理的内存划分为若干个不同的数据区域。这些区域都有各自的用途、创建和销毁的时间，有些区域随着虚拟机进程的启动而存在，有些区域则依赖用户线程的启动和结束而建立和销毁。
下图是Java虚拟机所管理的几个运行时数据区域图:

![java-memory](/imgs/jvm/Java-Memory.png)

## 线程隔离数据区 ##
所谓线程隔离数据区是指在多线程环境下，每个线程所独享的数据区域。主要有程序计数器、Java虚拟机栈、本地方法栈三个数据区。
### 程序计数器 ###
[程序计数器](http://baike.baidu.com/view/178145.htm?fr=aladdin) --- 计算机处理器中的寄存器，它包含当前正在执行的指令的地址（位置）。当每个指令被获取，程序计数器的存储地址加一。在每个指令被获取之后，程序计数器指向顺序中的下一个指令。当计算机重启或复位时，程序计数器通常恢复到零。
在Java中[程序计数器](http://baike.baidu.com/view/178145.htm?fr=aladdin)是一块较小的内存空间，充当当前线程所执行的字节码的行号指示器的角色。
在多线程环境下，当某个线程失去处理器执行权时，需要记录该线程被切换出去时所执行的程序位置。从而方便该线程被切换回来(重新被处理器处理)时能恢复到当初的执行位置，因此每个线程都需要有一个独立的[程序计数器](http://baike.baidu.com/view/178145.htm?fr=aladdin)。各个线程的[程序计数器](http://baike.baidu.com/view/178145.htm?fr=aladdin)互不影响，并且独立存储。
- 当线程正在执行一个java方法时，这个程序计数器记录的时正在执行的虚拟机字节码[指令](http://baike.baidu.com/view/178461.htm?fr=aladdin)的地址。
- 当线程执行的是[Native方法](http://www.enet.com.cn/article/2007/1029/A20071029886398.shtml),这个计数器值为空。
- 此内存区域是唯一一个在java虚拟机规范中没有规定任何OutOfMemoryError情况的区域。

### Java虚拟机栈 ###
Java虚拟机栈描述的是Java方法执行的内存模型，每个方法在执行的同时都会创建一个[栈帧](http://baike.baidu.com/view/8128123.htm?fr=aladdin)用于存储[局部变量表](http://blog.csdn.net/kevin_luan/article/details/22986081)、[操作数栈](http://denverj.iteye.com/blog/1218359)、[动态链接](http://jnn.iteye.com/blog/83105)、方法出口等信息。每个方法从调用直至执行完成的过程，对应着一个栈帧在虚拟机中入栈到进栈的过程。
- 如果线程请求的栈深度大于虚拟机所能允许的深度时将抛出*StackOverflowError异常(可以通过无限递归呈现此异常)
- 如果虚拟机在扩展时无法申请到足够的内存空间，则抛出OutOfMemoryError异常。

### 本地方法栈 ###
本地方法栈与虚拟机栈作用相似，区别在于虚拟机栈为虚拟机执行Java方法服务，而本地方法栈则为虚拟机使用到得Native方法服务。
- Sun HotSpot虚拟机将本地方法栈和虚拟机栈合二为一了。
- 其所会产生与Java虚拟机栈一样异常种类

## 线程共享数据区 ##
所谓线程共享数据区，是指在多线程环境下，该部分区域数据可以被所有线程所共享。主要有Java堆、方法区数据区。

### Java堆 ###
大多数情况下，Java堆是Java虚拟机所管理的内存中最大的一块。该内存区域被所有线程所共享。其中主要用于存放对象实例以及数组等。
- Java堆是垃圾收集器管理的主要区域。一般该区域又分为新生代和老年代(该部分会在Java垃圾收集器笔记中详述)。
- 当堆中无法存放最近一次产生的对象实例时便会产生OutOfMemoryError异常。

### 方法区 ###
Java方法区被各个线程共享的内存区域，它用于存储已被虚拟机加载的类信息、常量、静态变量、即时编译器编译后的代码等数据。很多时候这部分区别被称为永久代(Permanent Generation).垃圾收集行为在这个区域比较少出现，这个区域的内存回收目标主要针对常量池的回收和对类型的卸载。
- 当方法区无法满足内存分配需求时，将抛出OutOfMemoryError异常

### 运行时常量池 ###
运行时常量池(Runtime Constant Pool)是方法区的一部分。其用于存放Java编译期生成的各种字面量和符号引用。
- 运行期间也可能将新的常量放入常量池中，如String的intern()方法
- 当常量池无法申请到足够内存时会抛出OutOfMemoryError异常

## 直接内存 ##
直接内存(Direct Memory)并不是虚拟机运行时数据区的一部分，也不是Java虚拟机规范中定义的内存区域。
JDK1.4中出现了NIO，其引入了一种基于通道(Channel)与缓冲区(Buffer)的I/O方式，它可以使用[Native函数库](http://blog.csdn.net/gogor/article/details/6565665)直接分配堆外内存，然后通过一个存储在Java堆中得DirectoryByteBuffer对象作为这块内存的引用进行操作。这样可以避免Java堆和Native堆之间的来回复制数据。
- 当机器直接内存去除JVM内存之后的内存不能满足直接内存大小要求其，将会抛出OutOfMemoryError异常。

----

参考 [深入Java虚拟机](http://item.jd.com/11252778.html)/chapter02 Java内存区域与内存溢出异常
