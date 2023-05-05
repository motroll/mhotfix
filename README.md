
lua热更新 

本项目在windows下vscode打开可运行测试 
目录结构解析如下
  lib和include配置了lua5.4的c库和头文件 
  FileManage.cpp和FileManage.h用来进行检测需要更新的lua文件
  test 目录包含测试,测试类型有:闭包,返回表,全局表,全局函数,表引用和函数引用
  HotFix.lua 主要的lua更新代码


一个lua脚本是一个chunk,
在做正常的lua脚本加载的时候我们可以用到loadfile,dofile,require,以下统称为加载函数
loadfile 加载脚本不执行
dofile 加载脚本并执行脚本
require 只会执行一次,第二次加载的时候就不会执行 

这些函数对chunk进行加载的时候,会将chunk里面的全局变量设置到_G全局表里
如果chunk有返回值,加载函数会返回chunk里面的返回值,没有的时候加载成功会返回
true,package.load会将这些返回值存起来

在做热更新的时候,我们需要做的是将这些存储到_G或者package.load里面的变量替换成新的变量 
已经这些变量的引用进行替换。 

因为require只会执行一次,比较粗暴一点的方法是

if package.load[mod] then 
	package.load[mod] = nil 
end 
require(mod)

这样做,可以替换掉package.load里面的模块给替换掉,但是针对于 
FooServie = {} 
这样的写法,加载的时候会将FooService重新赋值空表,表里原有的数据丢失掉。
解决这个问题,我们可以使用如下写法:
FooServie = FooServie or {}  

这样的可以解决全局替换的数据稳定性问题,但是像
local printHello = FooServie.printHello 
这样的引用我们没法实现正常的更新,另外我们也不好保证程序员
在写全局变量都定义成code2写法,要是书写失误造成的数据丢失将是灾难性的。 

为了解决这样的问题,我们不得不找到一种比较稳定可靠的写法。在热更新的过程中,
加载函数能帮我们解决的是将chunk加载进来。我们希望做到是保证数据稳定性的替换。

那么我们需要解决的如下问题
Q1: 1.加载newchunk,获取newchunk里面的内容 2.找到oldchunk 3.将两个chunk进行对比修正 
Q2: 找到有这个chunk的数据变量的引用,替换成新chunk的变量

Q1.1 加载newchunk 
加载newchunk的时候,会对我们的全局变量造成污染。我们需要将chunk的_ENV替换成新的
_ENV. 只有lua5.1有setfenv函数。

chunk = loadfile(path)
local NewEnv = {}
setfenv(chunk,NewEnv)
chunk()

为了兼容所有的版本,在代码中我们需要自己手动实现了一个setfenv的函数,这里代码不贴出
在更新的过程中,我们发现全局的函数print和next等这些函数和基础库没办法继续使用.是因为我们
设定了新的环境变量。为了解决这个问题，我们可以采用将全局变量

local NewEnv = {_G = _G} 

或者将设置元表

local NewEnv = {} 
setmetable(NewEnv,{__indexx = _G}) 


Q1.2 代码写法中,通常我们的写法分为全局表写法和返回表写法。全局表写法,我们可以在_G全局表中找到,
返回表写法,我们可以在package.load里找到 

Q1.3 代码比较修正,需要修改的主要是函数和表,lua提供了debug.getupvalue,debug.upvaluejoin
和debug.setupvalue 


Q2 实现引用的替换.在上面的更新脚本中我们可以使用一个table来存储更新的数据。在debug.getregistry中
我们获取到之前加到的所有数据,我们可以对它进行一次遍历,对比到数据更新过就进行替换成更新过的数据。

到此,我们对lua的热更新基本就完成了。 总的原则就是关注代码中的函数和表数据,将旧的这些数据变更为替换过后的数据。 

