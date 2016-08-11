title: observer
date: 2015-11-19 14:02:44
categories: Design_Patterns
toc: true
---
## 概述 ##

>	观察者模式是对象的行为模式，又叫发布-订阅(Publish/Subscribe)模式、模型-视图(Model/View)模式、源-监听器(Source/Listener)模式或从属者(Dependents)模式。观察者模式定义了一种一对多的依赖关系，让多个观察者对象同时监听某一个主题对象。这个主题对象在状态上发生变化时，会通知所有观察者对象，使它们能够自动更新自己。		--- 阎宏《JAVA与模式》


## 类图 ##

![oberver](/imgs/patterns/observer.png)

## 基本实现 ##
观察者IObserver:
```java
public interface IObserver {

	//当通知到来时观察者的更新动作
	public void update(float temp);

	/**
	 * 观察者名称
	 * @return
	 */
	public String name();
}
```
具体观察者ConcreteObserver:
```java
public class ConcreteObserver implements IObserver {

	private String name;

	public ConcreteObserver(String name){
		this.name = name;
	}

	@Override
	public void update(float temp) {
		System.out.println(this.name + " --- receive subject state change:" + temp);
	}

	@Override
	public String name() {
		return this.name;
	}

}
```

观察主题ISubject:
```java
public interface ISubject {

	public void registerObserver(IObserver observer);

	public void removeObserver(IObserver observer);

	public void notifyObsevers();

	public void changeState(float temp);
}
```
具体观察主题ConcreteSubject:
```java
public class ConcreteSubject implements ISubject {

	private List<IObserver> observers;
	private float temp;

	public ConcreteSubject(){
		this.observers = new ArrayList<IObserver>();
	}

	@Override
	public void registerObserver(IObserver observer) {
		this.observers.add(observer);
		System.out.println("register one observer:" + observer.name());
	}

	@Override
	public void removeObserver(IObserver observer) {
		this.observers.remove(observer);
		System.out.println("remove one observer:" + observer.name());
	}

	@Override
	public void notifyObsevers() {
		for(IObserver observer: this.observers){
			observer.update(this.temp);
		}
	}

	@Override
	public void changeState(float temp){
		this.temp = temp;
		notifyObsevers();
	}

}
```
测试Main:
```java
public class Main {

	public static void main(String[] args) {

		//1.创建观察主题
		ISubject subject = new ConcreteSubject();

		//2.创建观察者
		IObserver observer1 = new ConcreteObserver("observer-1");
		IObserver observer2 = new ConcreteObserver("observer-2");
		IObserver observer3 = new ConcreteObserver("observer-3");

		//3.注册观察者
		subject.registerObserver(observer1);
		subject.registerObserver(observer2);
		subject.registerObserver(observer3);

		Random seed = new Random(100);
		for(int i = 0; i < 5; i++){
			System.out.println("-------------");
			subject.changeState(seed.nextFloat());
		}

		subject.removeObserver(observer1);
		subject.removeObserver(observer2);
		subject.removeObserver(observer3);
	}

}

```

## EventBus ##
[EventBus](http://www.cnblogs.com/peida/p/EventBus.html)是[Guava](http://ifeve.com/google-guava/)的事件处理机制，是设计模式中的观察者模式（生产/消费者编程模型）的优雅实现。对于事件监听和发布订阅模式，EventBus是一个非常优雅和简单解决方案，我们不用创建复杂的类和接口层次结构。

### 基本用法 ###

使用Guava之后, 如果要订阅消息, 就不用再继承指定的接口, 只需要在指定的方法上加上@Subscribe注解即可。也就说我们只要实现观察者就好了.

### 样例 ###

消息模型SimpleEvent:
```java
public class SimpleEvent {

	private String message;

	public SimpleEvent(String message){
		this.message = message;
	}

	public String getMessage() {
		return message;
	}

}
```

观察者SimpleEventListener:
```java
public class SimpleEventListener {

	@Subscribe
	public void listen(SimpleEvent event){
		System.out.println("simple listener listen:" + event.getMessage());
	}

	@Subscribe
	public void listen(Number numberEvent){
		System.out.println("simple listener listen:" + numberEvent.toString());
	}
}
```

测试SimpleEventBusTest:
```java
public class SimpleEventBusTest {

	public static void main(String[] args) {
		EventBus bus = new EventBus();

		SimpleEventListener listener = new SimpleEventListener();
		bus.register(listener);

		bus.post(new SimpleEvent("hello"));
		bus.post(new SimpleEvent("world"));
		bus.post(new SimpleEvent("!"));
		bus.post(new Long(2));
	}
}
```

---

参考:
* [Guava学习笔记：EventBus](http://www.cnblogs.com/peida/p/EventBus.html)
