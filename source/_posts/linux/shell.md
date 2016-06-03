title: Shell
date: 2015-11-06 11:08:51
categories: Linux
toc: true
---
## 基础语法 ##

### 变量 ###

(1) 使用一个定义过的变量，只要在变量名前面加美元符号（$）即可.变量名外面的花括号是可选的，加不加都行，加花括号是为了帮助解释器识别变量的边界.
(2) 只读变量，使用 readonly 命令可以将变量定义为只读变量，只读变量的值不能被改变
(3) 删除变量, 使用 unset 命令可以删除变量。变量被删除后不能再次使用；unset 命令不能删除只读变量。

```bash
#!/bin/bash

for skill in Ada Coffe Action Java 
do
    echo "I am good at ${skill}Script"
done

# readonly,unset
ro="ro"
un="unset"

echo "before readonly ro:${ro}, unset un:${un}"

unset un
readonly ro

echo "unset un:${un}"
ro="unro"

------------------ 输出 ------------------
I am good at AdaScript
I am good at CoffeScript
I am good at ActionScript
I am good at JavaScript
before readonly ro:ro, unset un:unset
unset un:
variable.sh: 18: variable.sh: ro: is read only

```

### 特殊变量 ###

|	变量	|    含义    | 
|    :------ 	|   :------  |   
|	$0	|	当前脚本的文件名    |
|	$n	|	传递给脚本或函数的参数。n 是一个数字，表示第几个参数。例如，第一个参数是$1，第二个参数是$2。|
|	$#	|	传递给脚本或函数的参数个数。|
|	$*	|	传递给脚本或函数的所有参数。|
|	$@	|	传递给脚本或函数的所有参数。被双引号(" ")包含时，与 $* 稍有不同。|
|	$?	|	上个命令的退出状态，或函数的返回值。|
|	$$	|	当前Shell进程ID。对于 Shell 脚本，就是这些脚本所在的进程ID|

* $* 和 $@ 都表示传递给函数或脚本的所有参数，不被双引号(" ")包含时，都以"$1" "$2" … "$n" 的形式输出所有参数。但是当它们被双引号(" ")包含时，"$*" 会将所有的参数作为一个整体，以"$1 $2 … $n"的形式输出所有参数；"$@" 会将各个参数分开，以"$1" "$2" … "$n" 的形式输出所有参数 *
```bash
curr_file_name=$0
input_params_count=$#
curr_pro_id=$$

echo "current bash file name:${curr_file_name}"
echo "current progress id:${curr_pro_id}"

echo "input params count:${input_params_count}"
echo "\$@ = $@"
echo "\$* = $*"

echo "\$? = $?"

----------------- 输出 -----------------
current bash file name:variable.sh
current progress id:11431
input params count:3
$@ = 1 2 3
$* = 1 2 3

```

### 替换变量和命令 ###

(1) 命令替换: 是指Shell可以先执行命令，将输出结果暂时保存，在适当的地方输出。
(2) 变量替换: 可以根据变量的状态（是否为空、是否定义等）来改变它的值

|	形式	|    说明    | 
|    :------ 	|   :------  |   
|	${var}	|	变量本来的值   |
|	${var:-word}	|	如果变量 var 为空或已被删除(unset)，那么返回 word，但不改变 var 的值。|
|	${var:=word}	|	如果变量 var 为空或已被删除(unset)，那么返回 word，并将 var 的值设置为 word。|
|	${var:+word}	|	如果变量 var 被定义，那么返回 word，但不改变 var 的值|

```bash
echo "current date: `date`"

age=${p1:-20}
echo "Undefined p1 for \${p1:-20} = ${age}, p1 = ${p1}"

num=${p2:=30}
echo "Undefined p2 for \${p2:=30} = ${num}, p2 = ${p2}"

count=${num:+40}
echo "defined num for \${num:+40} = ${count}, num = ${num}"

val=${p3:+50}
echo "Undefined p3 for \${p3:+50} = ${val}, p3 = ${p3}"

----------------- 输出-----------------
current date: 2015年 11月 06日 星期五 15:14:32 CST
Undefined p1 for ${p1:-20} = 20, p1 = 
Undefined p2 for ${p2:=30} = 30, p2 = 30
defined num for ${num:+40} = 40, num = 30
Undefined p3 for ${p3:+50} = , p3 = 

```

### 算术运算符 ###

`expr`是一款表达式计算工具，使用它能完成表达式的求值操作.注意表达式和运算符之间要有空格.如"2+2"是错误的，应该是"2 + 2"(空格).同时整个表达式要用"`"括起来！
```bash
p1=1
p2=2

val=`expr $p1 + $p2`
echo "${p1} + ${p2} = ${val}"

val=`expr $p1 - $p2`
echo "${p1} - ${p2} = ${val}"

val=`expr $p1 \* $p2`
echo "${p1} * ${p2} = ${val}"

val=`expr $p1 / $p2`
echo "${p1} / ${p2} = ${val}"

----------------- 输出 -----------------
1 + 2 = 3
1 - 2 = -1
1 * 2 = 2
1 / 2 = 0
```

### 关系运算符 ###

关系运算符只支持数字，不支持字符串，除非字符串的值是数字。
```bash
a=1
b=2
c=1

# -eq	检测两个数是否相等，相等返回 true。
if [ $a -eq $b ] 
then
	echo "${a} == ${b}"
else
	echo "${a} != ${b}"
fi

# -ne	检测两个数是否相等，不相等返回 true。
if [ $a -ne $b ] 
then
	echo "${a} != ${b}"
else
	echo "${a} == ${b}"
fi

# -gt	检测左边的数是否大于右边的，如果是，则返回 true。
if [ $b -gt $a ] 
then
	echo "${b} > ${a}"
else
	echo "${b} <= ${a}"
fi

# -ge	检测左边的数是否大等于右边的，如果是，则返回 true。
if [ $c -ge $a ] 
then
	echo "${c} >= ${a}"
else
	echo "${c} < ${a}"
fi

# -lt	检测左边的数是否小于右边的，如果是，则返回 true。
if [ $b -lt $a ] 
then
	echo "${b} < ${a}"
else
	echo "${b} >= ${a}"
fi

# -le	检测左边的数是否小于等于右边的，如果是，则返回 true
if [ $c -lt $a ] 
then
	echo "${c} <= ${a}"
else
	echo "${c} > ${a}"
fi

##################### 输出 #########################
1 != 2
1 != 2
2 > 1
1 >= 1
2 >= 1
1 > 1

```

### 布尔运算符 ###

`!`非,`-a`与,`-o`或 
```bash
d=0

if [ $d -gt 0 -a $d -lt 3 ]; then
	echo "0 < ${d} < 3"
elif [ $d -lt 0 -o $d -gt 3 ]; then
	echo "${d} < 0 | ${d} > 3"
else
	echo "${d} == 0 | ${d} == 3"
fi

----------------- 输出-----------------
0 == 0 | 0 == 3

```

### 字符串运算符 ###

```bash
msg1="hello"
msg2="world"
msg3="world"
msg4=""

# =	检测两个字符串是否相等，相等返回 true。	
if [ ${msg1} = ${msg2} ]; then
	echo "${msg1} = ${msg2}"
else
	echo "${msg1} != ${msg2}"
fi

# -z	检测字符串长度是否为0，为0返回 true。	
if [ -z ${msg4} ]; then
	echo "msg4's length is 0!"
fi

# -n	检测字符串长度是否为0，不为0返回 true。	
if [ -n ${msg3} ]; then
	echo "${msg3} is not null!"
fi

----------------- 输出 -----------------
hello != world
msg4's length is 0!
world is not null!
```
*注意未定义字符串的判断*
```bash
if [ -z $a ]; then
	echo "Undefined a length is 0!"
fi

if [ -n $a ]; then
	echo "Undefined a length is not 0!"
fi

if [ -z "$a" ]; then
	echo "Undefined a length is 0!"
fi

if [ -n "$a" ]; then
	echo "Undefined a length is not 0!"
fi

# 如果a为空或者没有赋值，那么a的值赋为0 (鸟哥的私房菜基础篇379页)
a=${a:-0}
if [ $a -eq 0 ]; then
	echo "\$a is null!"
fi 

----------------- 输出 -----------------
Undefined a length is 0!
Undefined a length is not 0!
Undefined a length is 0!
Undefined a length is 0!
$a is null!

```

### 文件测试运算 ###

```bash
file="/home/eagle/myspace/exercise/shell/demo.sh"

# -e file 检测文件（包括目录）是否存在，如果是，则返回 true。
if [ -e $file ]; then
	
	echo "$file exists!"

	# -d file 检测文件是否是目录，如果是，则返回 true。
	if [ -d $file ];then
	
		echo "$file is directory!"
	
	# -f file 检测文件是否是普通文件（既不是目录，也不是设备文件），如果是，则返回 true。
	elif [ -f $file ]; then
	
		echo "$file is file!"

		# -s file 检测文件是否为空（文件大小是否大于0），不为空返回 true。
		if [ -s $file ]; then
			
			echo "$file is not null!"

			# -r file 检测文件是否可读，如果是，则返回 true。
			if [ -r $file ]; then
				
				echo "$file can be read!"
			
			fi
		
		fi
	
	fi
	 	
else
	echo "$file not exists!"
fi

----------------- 输出 -----------------
/home/eagle/myspace/exercise/shell/demo.sh exists!
/home/eagle/myspace/exercise/shell/demo.sh is file!
/home/eagle/myspace/exercise/shell/demo.sh is not null!
/home/eagle/myspace/exercise/shell/demo.sh can be read!

```

### 字符串 ###

引号
单引号里的任何字符都会原样输出，单引号字符串中的变量是无效的；单引号字串中不能出现单引号（对单引号使用转义符后也不行）
双引号里可以有变量；双引号里可以出现转义字符

``` bash
msg="hello world!"

# 获取字符串长度
msg_length=${#msg}

# 获取字符位置
w_index=`expr index "${msg}" w`

# "#"从左边第一次出现查询字符o截取，保留右边字符
sub_msg=${msg#*o}

# "##"从左边最后一次出现查询字符o截取，保留右边字符
sub_msg2=${msg##*o}

# "%"从右边第一次出现查询字符o截取，保留左边字符
sub_msg3=${msg%o*}

# "%%"从右边最后一次出现查询字符o截取，保留左边字符
sub_msg4=${msg%%o*}

echo "${msg} length: ${msg_length}"
echo "w index of ${msg} is ${w_index}"
echo "sub_msg:${sub_msg}"
echo "sub_msg2:${sub_msg2}"
echo "sub_msg3:${sub_msg3}"
echo "sub_msg4:${sub_msg4}"

-----------------输出-----------------
hello world! length: 12
w index of hello world! is 7
sub_msg: world!
sub_msg2:rld!
sub_msg3:hello w
sub_msg4:hell

```

### 数组 ###

bash支持一维数组（不支持多维数组），并且没有限定数组的大小。类似与C语言，数组元素的下标由0开始编号。获取数组中的元素要利用下标，下标可以是整数或算术表达式，其值应大于或等于0。
```bash
#数组定义方式1
str_arr=("hello" "world" "!")

#数组定义方式2
num_arr[0]=1
num_arr[1]=2
num_arr[2]=3

# 获取数组中的所有元素
echo "str_arr:${str_arr[*]}"
echo "num_arr:${num_arr[@]}"

# 获取数组长度
str_arr_length=${#str_arr[*]}
echo "str_arr array length:${str_arr_length}"

-----------------输出 -----------------
str_arr:hello world !
num_arr:1 2 3
str_arr array length:3

```

### printf ###

printf 由POSIX标准所定义，移植性要比echo好.
printf 不像echo那样会自动换行，必须显式添加换行符(\n)。

```bash
n1=1
n2=2
s1="a"
s2="b"

printf "%d %s \n" $n1 $s1 $n2  $s2

# 如果没有 arguments，那么 %s 用NULL代替，%d 用 0 代替
printf "%d %s \n"

# 格式只指定了一个参数，但多出的参数仍然会按照该格式输出
printf "%s" a b c 

-----------------输出-----------------
1 a 
2 b 
0

```

### case esac语句 ###

```bash
# 读取输入，根据输入数字判断星期几。如果都不匹配则是非法数字。
read num

case $num in
	1 )
		echo "today is Monday!"
		;;
	2 )
		echo "today is Tuesday!"
		;;
	3 )
		echo "today is Wednesday!"
		;;
	4 )
		echo "today is Thursday!"
		;;
	5 )
		echo "today is Friday!"
		;;
	6 )
		echo "today is Saturday!"
		;;
	7 )
		echo "today is Sunday!"
		;;
	# 当以上所有都不匹配时执行
	* )
		echo "invalid numbser!"
	;;
esac
```

### 循环控制 ###

1. break
break命令允许跳出所有循环（终止执行后面的所有循环.`break n`代表跳出几层循环。
```bash
# 读取键盘输入的数字直到该数字是[1,5]

while :
do
	echo "input one number between 1 to 5"
	read number
	case $number in
		1|2|3|4|5)
			echo "valid number:${number}"
			break 
			;;
	esac

done
```

2.continue
continue命令与break命令类似，只有一点差别，它不会跳出所有循环，仅仅跳出当前循环.continue 后面也可以跟一个数字，表示跳出第几层循环。
```bash
arr=(1 2 3 4 5)

for number in ${arr[*]}
do
	echo $number
	m=`expr $number % 2`
	if [ ${m} -eq 0 ]; then
	 	echo "find even number:${number}"
	 	continue
	fi
	echo "find odd number:${number}"
done
```

## 常用命令 ##

### find ###

find命令可以沿着文件层次结构向下遍历，匹配符合条件的文件，并执行相应的操作。
```bash
# 在执行find命令的当前目录下查找文件名以md结尾的文件
$ find . -name "*.md"
# 同上，只是iname不区分字母大小写
$ find . -iname "*.md"
# 查询以".md"或".sh"结尾的文件
$ find . \( -name "*.md" -o  -name "*.sh" \) 
# 查询非".md"结尾的文件
$ find . ！-name "*.md" 
```
* -maxdepth 指定最大深度，find默认会查询当前目录以及所有子目录。
* -mindepth 指定最小深度

```bash
# 只查询当前目录，注意如果-type在-maxdepth之前，则linux会先查找所有文件然后再过滤最大深度
$ find . -maxdepth 1 -name "*.sh" -type f 
$ find . -mindepth 2 -name "*.sh" -type f
```
* 根据文件相关时间进行搜索:-atime,-ctime,-mtime单位:天，-amin,-cmin,-min单位:分钟

```bash
# 当前目录下，最近3天被访问的文件
$ find . -type f -atime -3
# 最近一天被修改
$ find . -type f -mtime -1
```
* 基于文件大小搜索:k(kb),-b(byte),-M(mbyte),-G(gbyte)

```bash
# 等于10k
$ find . -type f -size 10k
# 大于10k
$ find . -type f -size +10k
# 小于10k
$ find . -type f -size -10k
```
* 删除匹配文件

```bash
$ find . -type f -name "*.txt" -delete
```
* find结合-exec参数

```bash
# 将以".md"结尾的文件拷贝到bak目录下，注意后面要有"\;"
$ find . -type f -name "*.md" -exec cp {} bak \;
```
### xargs ###

通过管道符(|)，可以将一个命令的标准输入转换为另一个命令的标准输入。但，对于某些命令必须以参数的方式提供，此时便可通过xargs来实现。

* xargs将接收到的命令参数重新格式化

```bash
# 将多行输入转成单行输出(将\n用" "替换)
$ cat shell.md | xargs
# 通过下面的命令可以将单行输入通过" "分隔，指定每行参数个数
$ cat shell.md | xargs -n 3
# -d 指定自定义分隔符 
$ echo "helloworldhelloworld" | xargs -d o -n 1
```

* 参数输入

```bash
$ cat params.txt
hello
java
world
python

# 将该文件中的所有内容作为参数
$ cat parmas.txt | xargs -n 1 echo
# 参数替换
$ cat parmas.txt | xargs -I {} echo a-{}

a-hello
a-java
a-world
a-python
```

### tr ###

tr可对标准输入的字符进行替换、删除以及压缩。
```bash
# 大写转小写
$ echo "WHO ARE YOU" | tr 'A-Z' 'a-z'
# 去除数字
$ echo "WHO 3 4 ARE YOU" | tr -d '0-9'
# 压缩空白字符
$ echo "WHO 3 4    ARE    YOU" | tr -s ' '
输出: WHO 3 4 ARE YOU
```

### sort和uniq ###

```bash
$ cat a.dat 
jack 78
rose 79
tony 79
rose 79

$ sort a.data | uniq
jack 78
rose 79
tony 79

# 按数字倒序排列
$ sort -nr a.dat
tony 79
rose 79
rose 79
jack 78

# 按照第二列排序
$ sort -k 2 a.dat 
jack 78
rose 79
rose 79
tony 79

# -c该行的重复次数
$ sort a.dat | uniq -c
1 jack 78
2 rose 79
1 tony 79

# 找出重复的行
$ sort a.dat | uniq -d
rose 79
```
*uniq只能用于已经拍过序的数据输入*

### RADNOM生成随机数 ###

### 文件拆分 ###

```bash
$ ll a.dat
-rw-r--r-- 1 eagle eagle 32 11月 10 13:51 a.dat

# 将a.dat按照单个文件10byte拆分 
$ split -b 10 a.dat 
-rw-r--r-- 1 eagle eagle   10 11月 10 14:32 xaa
-rw-r--r-- 1 eagle eagle   10 11月 10 14:32 xab
-rw-r--r-- 1 eagle eagle   10 11月 10 14:32 xac
-rw-r--r-- 1 eagle eagle    2 11月 10 14:32 xad 

# -d 分割后的文件名以数字为后缀 -a 后缀长度 a_自定义前缀
$ split -b 10 a.dat -d -a 4 a
-rw-r--r-- 1 eagle eagle   10 11月 10 14:43 a_0000
-rw-r--r-- 1 eagle eagle   10 11月 10 14:43 a_0001
-rw-r--r-- 1 eagle eagle   10 11月 10 14:43 a_0002
-rw-r--r-- 1 eagle eagle    2 11月 10 14:43 a_0003

# 按照文件行数分隔 -l 行数
$ split -l 2 a.dat
```
截取文件前后缀:
```bash
file_name=some.jpg
file_name_prefix=${file_name%.*}
file_name_subfix=${file_name#*.}
```

## 文本操作 ##

### 生成指定大小的文件 ###

```bash
# if文件输入(input file), of(output file),bs文件大小(字节), count bs大小倍数 
$  dd if=/dev/zero of=junk.data bs=10M count=1
1+0 records in
1+0 records out
10485760 bytes (10 MB) copied, 0.0128509 s, 816 MB/s
```

### 文本文件交集和差集 ###

`comm`,参与比较的两个文件必须事先已被排过序!
```bash
$ cat a.dat 
s
t
q
c
g
t
o
$ cat b.dat 
g
g
r
c
h
s
o

# 文件排序
$ sort a.dat -o a.dat; sort b.dat -o b.dat

# 比较结果: 只在a.dat出现的字符	只在b.dat出现的字符	两个文件交集	
$ comm a.dat b.dat
		c
		g
	g
	h
		o
q
	r
		s
t
t

# 从输出结果中删除第一和第二列，得出的结果即为两者交集
$ comm a.dat b.dat -1 -2
c
g
o
s

```

### 统计文件行数和单词数以及字符数 ###

```bash
# 行数
$ wc -l a.dat
7 a.dat

# 字符数
$ wc -c a.dat
14 a.dat

# 单词数
$ wc -w a.dat
7 a.dat

# 打印最长行的长度
$ wc demo.sh -L
40 demo.sh
```

### 正则表达式 ###

![reg](/imgs/linux/reg.jpg)
![reg2](/imgs/linux/reg2.jpg)

### grep ###
```bash
$ grep ".jpg" demo.sh 
file_name=some.jpg'

# 反向
$ grep -v ".jpg" demo.sh 
#!/bin/bash

file_name_prefix=${file_name%.*}
file_name_subfix=${file_name#*.}

echo filename:${file_name}
echo filename prefix:${file_name_prefix}
echo filename subfix:${file_name_subfix}

# 包含搜索关键词的行数
$ grep -c "file" demo.sh 
6

$ grep -n "file" demo.sh 
3:file_name=some.jpg
5:file_name_prefix=${file_name%.*}
6:file_name_subfix=${file_name#*.}
8:echo filename:${file_name}
9:echo filename prefix:${file_name_prefix}
10:echo filename subfix:${file_name_subfix}

```

* 递归搜索

```bash
$ grep "file" . -R -n 
./shell/demo.sh:3:file_name=some.jpg
./shell/demo.sh:5:file_name_prefix=${file_name%.*}
./shell/demo.sh:6:file_name_subfix=${file_name#*.}
./shell/demo.sh:8:echo filename:${file_name}
./shell/demo.sh:9:echo filename prefix:${file_name_prefix}
./shell/demo.sh:10:echo filename subfix:${file_name_subfix}


# 多个匹配模式 -e
$ grep -e "prefix" -e "subfix" . -R -n 
./shell/demo.sh:5:file_name_prefix=${file_name%.*}
./shell/demo.sh:6:file_name_subfix=${file_name#*.}
./shell/demo.sh:9:echo filename prefix:${file_name_prefix}
./shell/demo.sh:10:echo filename subfix:${file_name_subfix}

```

* grep中包含或排除文件

```bash
$ grep "file_name" . -R -n --include *.{md}
$ grep "file_name" . -R -n --exclude *.{md}
./shell/demo.sh:3:file_name=some.jpg
./shell/demo.sh:5:file_name_prefix=${file_name%.*}
./shell/demo.sh:6:file_name_subfix=${file_name#*.}
./shell/demo.sh:8:echo filename:${file_name}
./shell/demo.sh:9:echo filename prefix:${file_name_prefix}
./shell/demo.sh:10:echo filename subfix:${file_name_subfix}

```

* 打印匹配文件之前之后的行

```bash
# 包含匹配之前两行
$ cat demo.sh | grep "prefix" -B 2
file_name=some.jpg

file_name_prefix=${file_name%.*}
--

echo filename:${file_name}
echo filename prefix:${file_name_prefix}

# 匹配行前后两行都输出
$ cat demo.sh | grep "prefix" -C 2
file_name=some.jpg

file_name_prefix=${file_name%.*}
file_name_subfix=${file_name#*.}

echo filename:${file_name}
echo filename prefix:${file_name_prefix}
echo filename subfix:${file_name_subfix}

```

### cut ###
```bash
$ cat a.dat 
NO	NAME	SCORE
1	jack	100
2	tony	99
3	spark	90

# cut默认以\t分隔，-f2,3 第二、三列
$ cut -f2,3 a.dat 
NAME	SCORE
jack	100
tony	99
spark	90

# 打印前5个字符
$ cut -c1-5 a.dat 
NO	NA
1	jac
2	ton
3	spa
```

### sed ###
```bash
$ cat a.dat 
NO	NAME	SCORE
1	jack	100
2	tony	99
3	spark	90

# 注意并未改变原始文件，g表示全局替换,如果没有此参数，则只替换匹配的第一处
$ sed 's/90/91/g' a.dat
NO	NAME	SCORE
1	jack	100
2	tony	99
3	spark	91

# 加上-i选项，同时改变原始文件
$ sed -i 's/90/91/g' a.dat
$ cat a.dat 
NO	NAME	SCORE
1	jack	100
2	tony	99
3	spark	91

# 3g 从第三次匹配开始替换
$ sed -i 's/91/911/3g' a.dat
$ cat a.dat 
NO	NAME	SCORE
1	jack	100
2	tony	99
3	spark	91

$ cat a.dat 
NO	NAME	SCORE
1	jack	100
2	tony	99
3	spark	91

4	java	98

# 移除匹配的空白行
$ sed  '/^$/d' a.dat 
NO	NAME	SCORE
1	jack	100
2	tony	99
3	spark	91
4	java	98

```

### awk ###

* 基本用法,awk "BEGIN{command} {command} END{command}" ,三个部分均可以省略

```bash
$ echo -e "line1\nline2" | awk 'BEGIN{ print "start"} {print} END{ print "END" }'
start
line1
line2
END
```

* awk中特殊变量

```bash
# NR:表示在执行过程中对应当前行号，NF:在执行过程中对应当前行的字段数，$0: 执行过程中当前行的内容，$1: 第一个字段的文本内容, $2: 第二个字段文本内容
$ echo -e "line1 f2 f3\nline2 f4 f5\nline3 f6 f7" | awk '{print "line no:"NR",No of fields:"NF", $0="$0", $1="$1", $2="$2}'
line no:1,No of fields:3, $0=line1 f2 f3, $1=line1, $2=f2
line no:2,No of fields:3, $0=line2 f4 f5, $1=line2, $2=f4
line no:3,No of fields:3, $0=line3 f6 f7, $1=line3, $2=f6

# 统计文件行数
$ awk 'END{print NR}' ./demo.sh 
10
```

* 使用awk进行行过滤

```bash
# 输出行号小于5的行
$ awk 'NR < 5' ./demo.sh 

# 输出第一到第4行
$ awk 'NR==1,NR==4' ./demo.sh

# 包含关键词"file_name"的行
$ awk '/file_name/' ./demo.sh 

# 迭代文件每行
$ cat demo.sh | (while read line; do echo $line ; done)
```
遍历一行数据的每个单词

```bash
#!/bin/bash 

line="hello shell"

for world in $line
do
	echo $world
done
```

通过for循环遍历

```bash
#!/bin/bash

line="hello shell"

for((i=0; i<${#line}; i++))
do 
	echo ${line:i:1}
done
```

--- 

参考:
- [Linux Shell脚本教程：30分钟玩转Shell脚本编程](http://c.biancheng.net/cpp/shell/) 
