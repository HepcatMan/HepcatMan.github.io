title: 对象
date: 2015-08-05 21:26:57
categories: Scala
toc: true
---
## 类 ##

### 简单类定义 ###

Scala中类的定义比较简单:class不需要`public`修饰，同一个源文件中可同时定义多个`class`,并且这些类都是公开的。

```scala
class Counter {

  private var value = 0
  
  def increment() {
    value += 1
  }
  
  def current() = value
}
```

调用:scala中对于不含参数的方法，则可以省略后面的括号。一般建议取值操作建议去掉空格!
```scala
object Demo{
  
  def main(args: Array[String]): Unit = {
    var obj1 = new Counter
     obj1.increment
     println(obj1.current)
     
//   var obj1 = new Counter()
//   obj1.increment()
//   println(obj1.current())
  }
}

输出: 1
```

### getter_setter方法 ###

scala对每个字段都提供getter和setter方法，将下面的代码保存为Person.scala:
```scala
class Person{
    var age = 10
}
```
编译成JVM字节码文件:`scalac Person.scala`.通过`javap -private Person.class`查看翻译后的java代码:
```java
Compiled from "Person.scala"
public class Person {
  //属性字段
  private int age;

  //由scala自动生成的getter/setter方法
  public int age();
  public void age_$eq(int);

  //构造方法
  public Person();
}
```
通过上面的java代码可以发现，翻译后的scala字段get/set方法并不是直接getXXX()/setXXX()！
scala中如果字段是私有的，则生成的getter/setter方法也是私有。因此，如果想自定义scala的get/set方法则可以将字段设置为`private`修饰的:
```scala
class Person{
	//生成私有getter/setter
	private var privateAge = 10
	
	//val修饰的只生成getter
	val name = "eagle"

	//不生成getter/setter
       private[this] var sex = "man" 
	
	//自定义get/set
	def age = privateAge

	def setAge(newVal: Int){
		privateAge = newVal	
	}
}
```
编译成JVM字节码文件:`scalac Person.scala`.通过`javap -private Person.class`查看翻译后的java代码:
```java
Compiled from "Person.scala"
public class Person {

  private int privateAge;
  private final java.lang.String name;
  //未生成任何get/set方法
  private java.lang.String sex;
  
  //private
  private int privateAge();
  private void privateAge_$eq(int);

  //val
  public java.lang.String name();

  //自定义方法get/set
  public int age();
  public void setAge(int);

  public Person();
}

```
注: 关于scala中字段自动生成setter/getter方法规则
- 如果字段是私有的(private)，则编译生成的class文件中的getter/setter方法也是私有的
- 如果字段是val的，则只生成getter方法
- 如果不想生成任何getter/setter方法，则可以使用private[this]修饰

### Bean属性 ###
由前面的介绍可知，虽然scala自动为属性字段生成了getter/setter方法，但是这些方法并不符合javabean规范。但是你可以通过scala提供的`@BeanProperty`来实现符合javabean规范的getter/setter方法:
```scala
import scala.reflect.BeanProperty
class Person{
	@BeanProperty var name: String = "eagle"
}
```
class文件:
```java
Compiled from "Person.scala"
public class Person {
  private java.lang.String name;

  public java.lang.String name();
  public void name_$eq(java.lang.String);
	
  //@BeanProperty生成的符合规范的getter/setter方法
  public void setName(java.lang.String);
  public java.lang.String getName();

  public Person();
}
```
### 主构造器 ###
在scala中每个类都有主构造器，主构造器并不是以this方法定义，而是与类定义交织在一起:
- 主构造器参数直接放在类名之后,主构造器参数会被编译成字段，其值被初始化成构造时传入的参数。
- 主构造器会执行类定义中的所有语句
- 通常在定义主构造器时同时指定默认参数
- 如果类名之后没有参数，则该类则具备一个无参主构造器。这样一个构造器会执行类体重的所有语句
- 构造参数也可以是不带val或var修饰，这样的参数如何处理则取决于它们在类中如何被使用.如果该参数至少被类中一个方法所使用，则该参数将被初始化不可变的私有为字段,效果类似`private[this] val`。否则，该参数将不被保存为字段!

- 主构造器可以由`private`关键字修饰，这样主构造器就变成私有了，而用户就只能调用该类的辅助构造器了

```scala
class Person(var name: String,val age: Int){
	println("name:" + name + ",age:" + age)
}

object Person{
  def main(args: Array[String]): Unit = {
    new Person("jack")
  }
}
输出:name=jack,age=30 -->
```

`javap -private Person.class`:

```java
public class com.jassassin.scala.chaptor567.Person extends java.lang.Object{
    //字段
    private java.lang.String name;
    private final int age;

    //设置默认值
    public static int $lessinit$greater$default$2();
    public static java.lang.String $lessinit$greater$default$1();

    //scala自动生成的name的getter/setter方法
    public java.lang.String name();
    public void name_$eq(java.lang.String);

    //val类型的age字段只生成getter方法
    public int age();

    //主构造函数
    public com.jassassin.scala.chaptor567.Person(java.lang.String, int);
}
```

构造参数不带`var`或`val`,被类中函数使用:

```scala
package com.jassassin.scala.chaptor567

class Person(name: String = "eagle",age: Int = 30) {
  //description函数使用到了主构造参数，则该参数被升格为私有字段。效果类似private[this] val
  def description = "name=" + name + ",age=" + age
}
```

```java
//javap:

public class com.jassassin.scala.chaptor567.Person extends java.lang.Object{
    //私有final
    private final java.lang.String name;
    private final int age;

    public static int $lessinit$greater$default$2();
    public static java.lang.String $lessinit$greater$default$1();

    //函数
    public java.lang.String description();

    public com.jassassin.scala.chaptor567.Person(java.lang.String, int);
}
```

构造参数不带`var`或`val`，未在类中使用:

```scala
class Person(name: String,age: Int) {
//  def description = "name=" + name + ",age=" + age
}
```

```java
//javap:

public class com.jassassin.scala.chaptor567.Person extends java.lang.Object{
    public com.jassassin.scala.chaptor567.Person(java.lang.String, int);
}
```

主构造器由`private`关键字修饰

```scala
class Person private(var name: String,val age: Int){
	 
}
```

```java
//javap
public class Person {
  private java.lang.String name;
  private final int age;
  public java.lang.String name();
  public void name_$eq(java.lang.String);
  public int age();
  
  //注意私有构造方法
  private Person(java.lang.String, int);
}
```

### 辅助构造器 ###
和Java和C++一样,Scala也可以有任意多的构造器.不过Scala中只有前面所述的一个主构造器以及任意多个辅助构造器.这些辅助构造器有以下几个特点:
- Scala中的辅助构造器的名称都是this
- 每个辅助构造器都必须以一个对先前已定义的其他辅助构造器或主构造器的调用开始

```scala
class Person {
	private var name = "eagle" 
	private var age = 20

	def this(name: String){
		this()
		this.name = name	
	}

	def this(name: String,age: Int){
		this(name)
		this.age = age	
	}	
}
```
```java
//javap

public class Person {
  private java.lang.String name;
  private int age;
  private java.lang.String name();
  private void name_$eq(java.lang.String);
  private int age();
  private void age_$eq(int);

  //三个构造器
  public Person();
  public Person(java.lang.String);
  public Person(java.lang.String, int);
}

```

### 嵌套类 ###
Scala中可以定义类似java中的内部类,而且scala中的嵌套类有着自己的特点.先看下面的示例:
```scala
package com.jassassin.blog.scala.demo.chaptor5

import scala.collection.mutable.ArrayBuffer

/**
 * 嵌套类
 */
class Company(var name: String) {
    
    /**
     * 公司部门
     */
    class Department(var name: String){
      val members = new ArrayBuffer[String]
    } 
    
    /**
     * 公司所有部门
     */
    private val departments = new ArrayBuffer[Department]
    
    /**
     * 为该公司添加部门
     */
    def join(dep: Department) = {
      departments += dep
      dep
    }
}

object Company{
  
  def main(args: Array[String]): Unit = {
      val networkbench = new Company("networkbench")
      val embracesource = new Company("embracesource")
      
      val dev1 = new networkbench.Department("dev1")
      val dev12 = new networkbench.Department("dev12")
      
      val ops = new embracesource.Department("ops")
      
      networkbench.join(dev1)
      networkbench.join(dev12)
       
       //注意这里添加了一个属于embracesource的部门
      networkbench.join(ops)
  }
  
}
```
`scalac Company.scala`编译,错误提示:
```java
 Company.scala:45: error: type mismatch;
 found   : embracesource.Department
 required: networkbench.Department
      networkbench.join(ops)
                        ^
one error found
```
上面错误提示networkbench不能添加embracesource的部门原因在于`scala中每个Company实例都有它自己的Department.`也就是说networkbench.Department和embracesource.Department是两个不同的数据类型!

#### 类型投影 ###

如果想产生类似java中的内部类特性,则可以将Department移至Company的外部.或者可以使用`类型投影 Company#Department`即"任何Company的Department"!
```scala
class Company(var name: String) {
    
    /**
     * 公司部门
     */
    class Department(var name: String){
      val members = new ArrayBuffer[String]
    } 
    
    /**
     * 公司所有部门
     */
    private val departments = new ArrayBuffer[Company#Department]
    
    /**
     * 为该公司添加部门
     */
    def join(dep: Company#Department) = {
      departments += dep
      dep
    }
}
```
## 对象 ##
当你需要某个类的单个实例，或者想为其他值或函数找一个可以挂靠的地方时，那么你可以考虑scala object语法。

### 单例对象 ###
Scala没有静态方法或静态字段，但你可以用object语法来达到同样的目的
```java
object Object {
  def main(args: Array[String]): Unit = {
      //连续调用5次
      for(i <- 1 to 5){
          println(Accounts.newUniqueNumber())
      }
  }
}

/**
 * object 类型
 */
object Accounts{
  
  private var lastNumber = 0;
  
  /**
   * 用于产生一个唯一number
   */
  def newUniqueNumber() = {
    lastNumber += 1
    lastNumber
  }
  
}
```
示例中的`Accounts`,只会在该类第一次使用时被初始化一次也就是说如果该类从未被使用，则其构造器也不会被执行。对于任何你在Java或C++中会使用单例对象的地方，在Scala中都可以用对象来实现(但不能提供构造器参数):
- 存放工具函数或常量
- 共享单个不可变实例
- 需要用单个实例来协调某个服务时

### 伴生对象 ###
在Java或C++中，通常会用到既有实例方法又有静态方法的类。在Scala中，你可以通过类和与类同名的"伴生"对象来达到同样的目的。 
```java
/**
 * object 类型
 * Accounts类的伴生对象
 */
object Accounts{
  
  private var lastNumber = 0;
  
  /**
   * 用于产生一个唯一number
   */
  private def newUniqueNumber() = {
    lastNumber += 1
    lastNumber
  }
  
}

class Accounts{
  
  //这里访问伴生对象的私有方法
  val id = Accounts.newUniqueNumber()
  
  private var balance = 0.0
  
  def deposit(amount: Double) {
    balance += amount
  }
  
}
```
当类和它的伴生对象在同个文件中时，类可以访问伴生对象的私有特性(虽有可以访问但是并不包含在类的作用域中，因此需要添加Accounts前缀)。

## 包 ##

## 继承 ##
