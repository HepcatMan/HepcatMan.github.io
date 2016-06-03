title: 控制结构以及函数
date: 2015-04-24 11:04:07
categories: Scala
toc: true
---
本文主要记录了Scala中的条件表达式、循环控制以及函数定义等内容!
## if语句 ##
scala中的`if/else`语句会有输出,因此可以将该输出赋值给其他变量. 示例:

```bash
scala> var x = 1
x: Int = 1

# 将if语句的结果赋值给变量y
scala> var y = if (x > 0) ">0" else "<0"
y: String = >0

# 如果if和else中返回的是不同类型，则会返回它们的公共父类型。
# 如下面的String和Int的超类型Any
scala> var r = if(x>1) "hello" else 0
r: Any = 0
```

`else`部分:

```bash
# 如果没有else部分,相当于 var z = if (x > 2) ">0" else ()
# "()"代表`没有值`的占位符,或者Unit类型(相当于java中的void)
scala> var z = if (x > 2) ">0" 
z: Any = ()

```

## 语句块 ##
scala中的语句块`{}`是有值的，该值是块中的最后一个表达式的值。注意对于赋值语句的表达式其结果是Unit类型，即结果为空(`()`).示例:

```bash
# 最后一个表达式"a + b"的结果赋值给了sum
scala> var sum = {var a =1; var b =2; a+b}
sum: Int = 3

scala> println(sum)
3

# 因为语句块的最后一个表达式是赋值表达式，因此sum2的结果是Unit类型
scala> var sum2 = {var a =1; var b =2}
sum2: Unit = ()

```

## 循环 ##
### while ### 
Scala中的while和do循环和java类似，示例:

```bash
var n = 10
while(n > 0){
     //scala中没有++或--操作符
     n -= 1
     println(n)
}
```
### for ### 
scala中没有类似java中的`for(int i = 0; i < b; i++){}`循环结构，在scala中常使用如下for循环:

```bash
var n = 10
for(i <- 1 to n){
   print(i + ",")
}
----------------------------输出--------------------------------
1,2,3,4,5,6,7,8,9,10,
```

对于`1 to n`实际是调用`RichInt`类的to方法返回1到数字n(包含n)的Range区间,而`for(i <- 表达式)`意思是让i遍历`<-`右边的表达式的所有值。
从上面示例代码输出可以看出`1 to n`是包含n的，而有时我们需要i的值从1到n-1,此时可以使用`until`方法，示例:

```bash
object cycle{
  
  def main(args: Array[String]): Unit = {
       var str = "jassassin"
       println(str + "length:" + str.length())
       for(index <- 0 until str.length()){
         println(str(index) + " --- " + index)
       }
       println("----------------------")
	//遍历方式二
       for(char <- str){
         print(char + " ")
       }
  }
  
}
----------------------------输出--------------------------------
//注意index值从0->8并未到9
jassassin length:9
j --- 0
a --- 1
s --- 2
s --- 3
a --- 4
s --- 5
s --- 6
i --- 7
n --- 8  
----------------------
j a s s a s s i n 

```

### 高级for循环 ###

scala中的for循环可以以`变量 <- 表达式`形式提供多个生成器，并用分号进行分隔，示例:

```bash
for(i <- 1 to 3; j <- 1 until 3; k <- 1 to 3){
   print(i * 100 + j * 10 + k + " ")
}
----------------------------输出--------------------------------
111 112 113 121 122 123 211 212 213 221 222 223 311 312 313 321 322 323 
```

`变量 <- 表达式`可以同时携带一个if开头的Boolean表达式:

```bash
//注意"k <- 1 to 3 if k != i",if之前并没有";"
for(i <- 1 to 3; j <- 1 until 3; k <- 1 to 3 if k != i){
  print(i * 100 + j * 10 + k + " ")
}
----------------------------输出--------------------------------
112 113 122 123 211 213 221 223 311 312 321 322
```

### for推导式 ### 
如果for循环的循环体以`yield`开头，则该循环会构造一个集合,每次迭代会生成该集合中的一个值:

```bash
scala> for(i <- 0 to 10) yield i
res1: scala.collection.immutable.IndexedSeq[Int] = Vector(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
scala> for(i <- 0 to 10) yield {i+1}
res2: scala.collection.immutable.IndexedSeq[Int] = Vector(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11)
```

## 函数 ## 
### 函数定义 ### 
scala中的函数以`def`开头,示例:

```bash
scala> def abs(x: Double) = if(x > 0) x else -x
abs: (x: Double)Double

scala> abs(-19)
res3: Double = 19.0

```
Scala中的函数参数必须给出参数的类型(x: Double)，同时scala编译器可以通过`=`右侧的表达式推测出返回值类型!但是对于递归函数则必须指定返回值类型:

```bash
scala> def fac(n: Int): Int = if(n <= 0) 1 else n * fac(n-1)
fac: (n: Int)Int

scala> fac(3)
res4: Int = 6

```
如何函数块中含有多行代码，则可以用`{}`包括进来!同时该代码块的最后一行表达式是该函数的返回值。见本文`语句块`!

```bash
def fac(n: Int) = {
   var r = 1

   for(i <- 1 to n){
      r = r * i
    }
    //该的值即为函数返回值
   r
}

def main(args: Array[String]): Unit = {
  println(fac(5))
}
----------------------------输出--------------------------------
120
```
注:Scala中的`return`语句常用在匿名函数中，相当于函数break.用于跳出当前匿名函数到包含它的外围有名函数中去!

### 函数参数 ###
#### 默认参数 ####
示例:

```bash
# p2,p3均有默认参数
scala> def output(p1: String,p2: String = "[",p3: String = "]") = p2 + p1 + p3
ouput: (p1: String, p2: String, p3: String)String

# 使用默认参数
scala> output("jassassin")
res6: String = [jassassin]

# 使用自定义参数
scala> output("jassassin","<<",">>")
res7: String = <<jassassin>>

scala> output("jassassin","<<")
res8: String = <<jassassin]

```

#### 带名参数 ####

调用scala函数传递参数时，可以同时传递参数名称，这样调用函数的参数顺序可以自由排列。如上面的ouput函数:

```bash
scala> output(p3=">",p1="eagle",p2="<")
res3: String = <eagle>
```

#### 可变长参数 ####

如下可接受可变长参数的函数:

```bash
def sum(arg: Int*) = {
    var sum = 0
    for(i <- arg){
      sum += i
    }
    sum
}

//调用
sum(1,2,3,4)
----------------------------输出--------------------------------
10
```

注:如果调用此函数时传递的是单个参数，则该参数必须是单个整数，而不是一个整数区间!

```bash
scala> sum(1 to 5)
<console>:9: error: type mismatch;
 found   : scala.collection.immutable.Range.Inclusive
 required: Int
              sum(1 to 5)
                    ^
```

解决方式:追加`_*`

```bash
scala> sum(1 to 5: _*)
res6: Int = 15
```

## 过程 ##
如果函数体包含在`{}`中，但是前面没有"="。则称这样函数为过程!过程不返回值，调用它只是为了它的副作用，如下面的打印参数:

```bash
scala> def p(arg: String){print(arg)}
p: (arg: String)Unit

scala> p("eagle")
eagle
```

通常建议的写法是显示声明函数返回值为`Unit`,从而尽量提醒比如java程序员习惯性的误调用!

```bash
scala> def out(arg: String): Unit = {print(arg)}
out: (arg: String)Unit

scala> out("eagle")
eagle

# 这里定义变量result期望获取out()函数的输出"eagle",而实际获得的是Unit
scala> var result = out("eagle")
eagleresult: Unit = ()

scala> print(result)
()
```
## 惰性初始化 ##
当val类型的变量被`lazy`修饰时，那么该变量的初始化将被延迟至它第一次被访问。该特性常用于初始化开销比较大的应用，如文件读取!
## 异常 ## 
Scala中的异常和java中的基本一致，不同的是scala中没有"检查"型异常。因此scala中的方法签名中不会显示的标识`someMethod() throws IOException,XXException ...` 

