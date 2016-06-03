title: 数组&集合
date: 2015-04-25 21:24:42
categories: Scala
toc: true
---
本文主要记录Scala中的数组(定长数组与可变长数组)定义以及常用操作,同时将映射(类似java中的集合类)以及元组也放在了这里!
## 数组 ##
### 定长数组 ### 
在JVM中，Scala的Array以Java数组的方式实现。Int、Double或其他与Java中基本类型对应的数组都是基本类型数组。比如Array("a","b","c")在JVM中就是一个String[]。下面是使用Scala中得Array实现的长度不变的数组:

```bash
# 长度为5的Int类型的定长数组，初始值都是0
scala> val nums = new Array[Int](5)
nums: Array[Int] = Array(0, 0, 0, 0, 0)

# 长度为5的String类型的定长数组，初始值都是null
scala> val a = new Array[String](5)
a: Array[String] = Array(null, null, null, null, null)

# 长度为2的String类型的定长数组，直接初始化
scala> val s = Array("jassassin","eagle")
s: Array[String] = Array(jassassin, eagle)

# 数组长度不可改变
scala> s(2) = "bye"
java.lang.ArrayIndexOutOfBoundsException: 2
  ... 33 elided

# 注意数组中的值的访问形式是通过"()"，而不是"[]"
scala> s(1) = "bye"
```
注: * 数组元素的访问方式是`s(1)`而不是`s[1]`*	

### 可变长数组ArrayBuffer ###
Scala中使用ArrayBuffer,实现类似java中得ArrayList可变长数组。下面的示例是我在terminal中测试的

```bash
# 引入ArrayBuffer类
scala> import scala.collection.mutable.ArrayBuffer
import scala.collection.mutable.ArrayBuffer

# 定义Int类型的ArrayBuffer
scala> val arr = ArrayBuffer[Int]()
arr: scala.collection.mutable.ArrayBuffer[Int] = ArrayBuffer()

# 使用"+="在尾端添加元素
scala> arr += 1
res5: arr.type = ArrayBuffer(1)

# 使用"+="在尾端添加元素，多个元素用"()"括起来
scala> arr += (1,2,3,4,5)
res7: arr.type = ArrayBuffer(1, 1, 2, 3, 4, 5)

# 使用"++="追加集合
scala> arr ++= Array(1,2,3,4,5)
res8: arr.type = ArrayBuffer(1, 1, 2, 3, 4, 5, 1, 2, 3, 4, 5)

# 去除最后5个元素
scala> arr.trimEnd(5)

scala> println(arr)
ArrayBuffer(1, 1, 2, 3, 4, 5)

# 去除第一个元素
scala> arr.trimStart(1)

scala> println(arr)
ArrayBuffer(1, 2, 3, 4, 5)
```
你也可以像下面这样将上面的代码写入Demo.scala文件中:

```java
import scala.collection.mutable.ArrayBuffer

/**
  @autor jassassin
  @description Scala数组 
*/
object Demo{
    
	def main(args: Array[String]): Unit = {

		//定义可变长的Int数组ArrayBuffer
		val arr = ArrayBuffer[Int]()

		arr += 1
		arr += (1,2,3,4,5)
		arr ++= Array(1,2,3,4,5)

		printArr(arr)

		println("\n-------trimEnd(3)------------")
		arr.trimEnd(3)
		printArr(arr)
	}

	/**
	 打印ArrayBuffer
	*/
	def printArr(arr: ArrayBuffer[Int]){
		print("arr:")
		for(i <- arr){
			print(i + " ")
		}
		//换行
		println()
	}
}


RUN: scala Demo.scala
----------------------------输出--------------------------------
arr:1 1 2 3 4 5 1 2 3 4 5 

-------trimEnd(3)------------
arr:1 1 2 3 4 5 1 2 
```

对于ArrayBuffer，如果在数组中间插入元素由于需要将插入位置之后的所有后移，因此效率相对较低!

```bash
# 在数组角标1处插入元素0
scala> arr.insert(1,0)

scala> println(arr)
ArrayBuffer(1, 0, 2, 3, 4, 5)

# 在数组角标6处插入多个元素“6,7,8”
scala> arr.insert(6,6,7,8)

scala> println(arr)
ArrayBuffer(1, 0, 2, 3, 4, 5, 6, 7, 8)      

# 移除数组角标1的元素
scala> arr.remove(1)
res19: Int = 0

scala> println(arr)
ArrayBuffer(1, 2, 3, 4, 5, 6, 7, 8)

# 移除数组角标5之后的三个元素
scala> arr.remove(5,3)

scala> println(arr)
ArrayBuffer(1, 2, 3, 4, 5)
```
注: *上面的所有操作除`trimStart/trimEnd`操作位置索引是从1开始外，其他操作都是从0开始*

### 定长数组与可变数组的相互转换 ###
有时想使用定长数组，但又不知道其长度。此时先定义一个可变长数组，然后在适当的时候将其转换成定长数组,反之也可以:

```bash
# 将前面的ArrayBuffer转为Array
scala> arr.toArray
res25: Array[Int] = Array(1, 2, 3, 4, 5)

scala> val z = Array("jassassin","eagle")
z: Array[String] = Array(jassassin, eagle)

# 将前后的Array转为ArrayBuffer
scala> z.toBuffer
res24: scala.collection.mutable.Buffer[String] = ArrayBuffer(jassassin, eagle)
```

### 数组遍历 ###
你可以通过`Int.until(n)`方法遍历角标`0->n-1`的方式来实现数组的遍历:

```bash
# i取值从0到arr.length-1
scala> for(i <- 0 until arr.length){print(arr(i) + " ")}
1 2 3 4 5 
# 通过(0 until arr.length).reverse实现倒序遍历
scala> for(i <- (0 until arr.length).reverse){print(arr(i) + " ")}
5 4 3 2 1 
```
也可以通过类似java中得增强for循环直接遍历数组中得元素:
```bash
scala> for(i <- arr){print(i + " ")}
1 2 3 4 5 
```
### 数组转换 ###
结合for推导，可以基于已有的数组方便的创建一个新的数组:

```bash
scala> val y = Array(1,2,3,4,5)
y: Array[Int] = Array(1, 2, 3, 4, 5)

scala> val yy = for(element <- y if element % 2 == 0)yield 2 * element
yy: Array[Int] = Array(4, 8)
```
### 常用方法 ###
数组提供了很多常用的方法来对其中的元素进行求和以及排序等:

```bash
scala> y.sum
res33: Int = 15

scala> y.max
res34: Int = 5

scala> y.min
res35: Int = 1

# 通过scala.util.Sorting对数组o排序
scala> val o = Array(1,7,3,2,9)
o: Array[Int] = Array(1, 7, 3, 2, 9)

scala> scala.util.Sorting.quickSort(o)

scala> for(i <- o){print(i + " ")}
1 2 3 7 9 

# 以指定分隔符构建字符串的形式输出数组结果
scala> y.mkString(" and ")
res46: String = 1 and 2 and 3 and 4 and 5

# 更进一步指定输出的前后缀
scala> y.mkString("<",",","> ")
res47: String = "<1,2,3,4,5> "
```
注: 对于上面的`min`,`max`,`quickSort`方法，数组的元素类型必须支持比较操作!

## 映射 ##
所谓映射即键值对集合！
### 创建映射 ###
你可以通过如下几种方式，创建一个映射:

```bash
# 默认创建不可变Map
scala> val scores = Map("jack" -> 99,"tony" -> 89,"rose" -> 88)
scores: scala.collection.immutable.Map[String,Int] = Map(jack -> 99, tony -> 89, rose -> 88)

# 这里尝试更新不可变Map scores中的值
scala> scores("jack") = 100
<console>:9: error: value update is not a member of scala.collection.immutable.Map[String,Int]
              scores("jack") = 100
              ^

# 显示创建可变Map
scala> val scores2 = scala.collection.mutable.Map("jack" -> 99,"tony" -> 89,"rose" -> 88)
scores2: scala.collection.mutable.Map[String,Int] = Map(jack -> 99, rose -> 88, tony -> 89)

# 创建一个空的可变Map
scala> val scores3 = new scala.collection.mutable.HashMap[String,Int]
scores3: scala.collection.mutable.HashMap[String,Int] = Map()

# 初始化不可变Map的另外一种形式，不推荐!
scala> val scores4 = Map(("jack",99),("tony",89),("rose",88))
scores4: scala.collection.immutable.Map[String,Int] = Map(jack -> 99, tony -> 89, rose -> 88)
```
### 获取映射中的值 ###
你可以通过如下方式访问集合中某个键对应的值:

```bash
scala> val jackScore = scores("jack")
jackScore: Int = 99
```
前面这种方式当映射中不包含查询的键时，将会抛出异常:

```bash
scala> val noScore = scores("eagle")
java.util.NoSuchElementException: key not found: eagle
	at scala.collection.MapLike$class.default(MapLike.scala:228)
```
为避免上面的问题，可以先进行判断:
```bash
# 先判断
scala> val noScore = if(scores.contains("eagle")) scores("eagle") else 0
noScore: Int = 0
```
简化方式,使用`getOrElse`方法:
```bash
scala> val noScore2 = scores.getOrElse("eagle",0)
noScore2: Int = 0
```
### 更新映射中的值 ###
可以通过下面的方式更新或添加某个`可变映射`的值。示例:

```bash
# 定义可变Map
scala> val name_age =new scala.collection.mutable.HashMap[String,Int]
name_age: scala.collection.mutable.HashMap[String,Int] = Map()

# 添加键值对
scala> name_age += ("jack" -> 20,"tony" -> 30)
res1: name_age.type = Map(jack -> 20, tony -> 30)

# 更新某个键值
scala> name_age("jack") = 25

scala> print(name_age)
Map(jack -> 25, tony -> 30)

# 删除某个键
scala> name_age -= "tony"
res5: name_age.type = Map(jack -> 25)
```
虽然不可变映射不能改变其值，但是可以基于该不可变映射创建一个新的映射:
```bash
# 这是前面定义的不可变scores
scala> print(scores)
Map(jack -> 99, tony -> 89, rose -> 88)

# 基于scores创建一个新的Map，同时更新了"jack"的值，并追加了键值对("eagle" -> 99)
scala> val newScores = scores + ("jack" -> 100,"eagle" -> 99)
newScores: scala.collection.immutable.Map[String,Int] 
			= Map(jack -> 100, tony -> 89, rose -> 88, eagle -> 99)

# 通过"-"，删除不可变映射中的某个元素创建一个新的映射
scala> val newScores2 = newScores - "eagle"
newScores2: scala.collection.immutable.Map[String,Int] = Map(jack -> 100, tony -> 89, rose -> 88)
```
### 迭代映射 ###

遍历所有kv:
```bash
scala> for((k,v) <- scores){println(k + "->" + v)}
jack->99
tony->89
rose->88
```
遍历所有key:
```bash
# 取出映射的keySet集合
scala> for(key <- scores.keySet){println(key)}
jack
tony
rose
```
遍历所有value:

```bash
scala> for(value <- scores.values) println(value)
99
89
88
```
反转映射的k->v:

```bash
scala> val invertScores = for((k,v) <- scores) yield (v,k)
invertScores: scala.collection.immutable.Map[Int,String] = Map(99 -> jack, 89 -> tony, 88 -> rose)

scala> println(invertScores)
Map(99 -> jack, 89 -> tony, 88 -> rose)
```
## 元组 ##
元组可以用来包含不同元素类型的数据，因此其可以用于函数需要返回不止一个值的情况!元组的定义比较简单，访问元组指定位置的元素可以通过`tuple._index`来访问!示例:

```bash
# 定义一个元组t
scala> val t = (1,3.14,"hello")
t: (Int, Double, String) = (1,3.14,hello)

# 访问元组中的位置1上的元素
scala> println(t._1)
1
```
注:*元组中的元素角标索引是从1开始而不是0!*

### 拉链操作 ###
使用元组的原因之一就是可以将多个值绑在一起，以便它们可以一起处理。通过`zip`方法可以很方便的实现将两个数组进行绑定:
```bash
scala> val symbols = Array("<","-",">")
symbols: Array[String] = Array(<, -, >)

scala> val counts = Array(1,2,3)
counts: Array[Int] = Array(1, 2, 3)

scala> val pairs = symbols.zip(counts)
pairs: Array[(String, Int)] = Array((<,1), (-,2), (>,3))
```
