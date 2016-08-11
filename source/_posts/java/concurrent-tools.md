title: concurrent tools
date: 2015-04-10 15:13:36
categories: Java
toc: true
---
## 引文 ##
同步工具类可以使任何一种对象，只要该对象可以根据自身的状态来协调控制线程的控制流。阻塞队列可以作为同步工具类，其他类型的同步工具类还包括：信号量（Semaphore）、栅栏（Barrier）以及闭锁（Latch）等。
## 1. 闭锁CountDownLatch ##
CountDownLatch 闭锁: 可以延迟线程的进度，直到锁到达终止状态。闭锁的作用相当于一扇门，在锁到达终止状态之前这扇门一直是关闭的。当锁到达终止状态时，允许所有线程通过。CountDownLatch有一个初始值，通过调用`countDown`方法可以减少该值，一直到0时到达终止状态。
闭锁可以用来确保某些活动直到其它活动都完成后才继续执行，例如：
1. 确保某个计算在其所有资源都被初始化之后才继续执行。二元闭锁（只有两个状态）可以用来表示“资源R已经被初始化”，而所有需要R操作都必须先在这个闭锁上等待。

<!--more-->

2. 确保某个服务在所有其他服务都已经启动之后才启动。这时就需要多个闭锁。让S在每个闭锁上等待，只有所有的闭锁都打开后才会继续运行。
3. 等待直到某个操作的参与者（例如，多玩家游戏中的玩家）都就绪再继续执行。在这种情况下，当所有玩家都准备就绪时，闭锁将到达结束状态。

Demo:
```java
import java.util.concurrent.CountDownLatch;

/**
 * 闭锁  延迟线程进度直到线程到达某个状态
 * @author eagle
 * @date 2015年4月14日
 */
public class CountDownLatchDemo {

	public static void main(String[] args) throws InterruptedException {
		//count(2): 在线程通过此闭锁门之前，CountDownLatch的countDown方法必须被线程调用的次数
		CountDownLatch latch = new CountDownLatch(2);
		Worker worker1 = new Worker(latch);
		Worker worker2 = new Worker(latch);

		//启动线程
		worker1.start();
		worker2.start();

		//await()方法则阻塞，直到计数器值count变为0
		latch.await();

		System.out.println(Thread.currentThread().getName() + ": over!");
	}


	private static class Worker extends Thread{
		private CountDownLatch latch;

		public Worker(CountDownLatch latch){
			this.latch = latch;
		}

		@Override
		public void run() {
			System.out.println(Thread.currentThread().getName() + ": running!");
			try {
				Thread.sleep(1000);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
			latch.countDown();
		}
	}
}
```
## 2. FutureTask ##
FutureTask: 用于执行一个可返回结果的长任务，任务在单独的线程中执行，其他线程可以用`get`方法取任务结果，如果任务尚未完成，线程在get上阻塞。
FutureTask也可以用作闭锁。它表示一种抽象的可生成结果的计算。是通过`Callable`来实现的，相当于一种可生成结果的`Runnable`，并且可处于以下三种状态：等待运行，正在运行，运行完成。当FutureTask进入完成状态后，它会停留在这个状态上。`Future.get`方法用来获取计算结果，如果FutureTask还未运行完成，则会阻塞。FutureTask将计算结果从执行计算的线程传递到获取这个结果的线程，而FutureTask 的规范确保了这种传递过程能实现结果的安全发布。FutureTask在Executor框架中表示异步任务，还可以用来表示一些时间较长的计算。
![futureTask](/imgs/java/futureTask.jpg)
Demo:
```bash
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.FutureTask;

/**
 * FutureTask可以作为闭锁使用。该类的计算是通过Callable实现的，它等价于一个可携带结果的Runnable，
 * 并且有3个状态:等待、运行、完成
 * 完成包括所有计算以任意的方式结束，包括正常结束、取消和异常
 * @author eagle
 * @date 2015年4月15日
 */
public class FutureTaskTest {

	public static void main(String[] args) throws InterruptedException, ExecutionException {
		ExecutorService executorService = Executors.newFixedThreadPool(2);
		FutureTask<String> futureTask = new FutureTask<String>(new Task());
		//启动task线程
		executorService.submit(futureTask);
		//住线程继续运行
		System.out.println("main thread run over!");
		//检查task是否执行完毕
		while(!futureTask.isDone()){
			System.out.println("futureTask status is running!");
		}
		System.out.println("task run over!");
		//获取线程执行结果，这里会阻塞直到线程执行完毕返回结果
		String result = futureTask.get();
		System.out.println("task run result:" + result);
		executorService.shutdown();
	}

	private static class Task implements Callable<String>{

		@Override
		public String call() throws Exception {
			Thread.sleep(10);
			System.out.println("task be called!");
			return "task";
		}

	}

}
```
## 3. Semaphore ##
Semaphore信号量:
- 用于控制同时访问某资源，或同时执行某操作的线程数目。Semaphone管理这一组许可（permit），可通过构造函数指定。提供了阻塞方法`acquire`，用来获取许可。同时提供了`release`方法表示释放一个许可。
- 之前的闭锁控制的是访问时间，而信号量则用来控制访问某个特定资源的操作数量，控制空间。而且闭锁只能够减少，一次性使用，而信号量则申请可释放，可增可减。 计数信号量还可以用来实现某种资源池，或者对容器施加边界。
- Semaphone可以将任何一种容器变为有界阻塞容器，如用于实现资源池。例如数据库连接池。我们可以构造一个固定长度的连接池，使用阻塞方法 acquire和release获取释放连接，而不是获取不到便失败。

Demo:
```java
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Semaphore;

/**
 * Semaphore实现的功能就类似厕所有5个坑，假如有10个人要上厕所，那么同时只能有多少个人去上厕所呢？
 * 同时只能有5个人能够占用，当5个人中 的任何一个人让开后，其中等待的另外5个人中又有一个人可以占用了。
 * 另外等待的5个人中可以是随机获得优先机会，也可以是按照先来后到的顺序获得机会，这取决于构造Semaphore对象时
 * 传入的参数选项。单个信号量的Semaphore对象可以实现互斥锁的功能，并且可以是由一个线程获得了“锁”，
 * 再由另一个线程释放“锁”，这可应用于死锁恢复的一些场合。
 * @author eagle
 * @date 2015年4月15日
 */
public class SemaphoreTest {

	public static void main(String[] args) {
		ExecutorService executorService = Executors.newCachedThreadPool();
		//初始化5个许可证
		Semaphore semaphore = new Semaphore(5);
		//启动50个线程运行
		for(int i = 0; i < 50; i++){
			executorService.submit(new Task(semaphore));
		}
		executorService.shutdown();
	}

	private static class Task implements Runnable{

		private Semaphore semaphore;

		public Task(Semaphore semaphore){
			this.semaphore = semaphore;
		}

		@Override
		public void run() {
			try {
				semaphore.acquire();
				System.out.println(Thread.currentThread().getName()
							+ " is running!");
				Thread.sleep(1000);
				semaphore.release();
				 System.out.println("------" + semaphore.availablePermits());
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}

	}

}
```

## 4. CyclicBarrier ##
CyclicBarrier栅栏: 用于多个线程多次迭代时进行同步，在一轮任务中，任何线程完成任务后都在`barrier`上等待，直到所有其他线程也完成任务，然后一起释放，同时进入下一轮迭代。
栅栏（Bariier）类似于闭锁，它能阻塞一组线程知道某个事件发生。栅栏与闭锁的关键区别在于，所有的线程必须同时到达栅栏位置，才能继续执行。闭锁用于等待等待时间，而栅栏用于等待线程。
CyclicBarrier可以使一定数量的参与方反复的在栅栏位置汇聚，它在并行迭代算法中非常有用：将一个问题拆成一系列相互独立的子问题。当线程到达栅栏位置时，调用await()方法，这个方法是阻塞方法，直到所有线程到达了栅栏位置，那么栅栏被打开，此时所有线程被释放，而栅栏将被重置以便下次使用.
Demo:
```java
import java.util.concurrent.BrokenBarrierException;
import java.util.concurrent.CyclicBarrier;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * 一个同步辅助类，它允许一组线程互相等待，直到到达某个公共屏障点 (common barrier point)。
 * 在涉及一组固定大小的线程的程序中，这些线程必须不时地互相等待，此时 CyclicBarrier 很有用。因为该 barrier
 * 在释放等待线程后可以重用，所以称它为循环 的 barrier
 * @author eagle
 * @date 2015年4月15日
 */
public class CyclicBarrierTest {

	public static void main(String[] args) {
		ExecutorService executorService = Executors.newCachedThreadPool();

		//注意，这里CyclicBarrier构造传入的parties参数值是3，那么应该有三个线程，否则会一直阻塞下去
		CyclicBarrier cyclicBarrier = new CyclicBarrier(3);

		executorService.submit(new Runner(cyclicBarrier, "jack"));
		executorService.submit(new Runner(cyclicBarrier, "rose"));
		executorService.submit(new Runner(cyclicBarrier, "tony"));

		executorService.shutdown();
	}

	private static class Runner implements Runnable{

		private CyclicBarrier cyclicBarrier;
		private String name;

		public Runner(CyclicBarrier cyclicBarrier, String name) {
			super();
			this.cyclicBarrier = cyclicBarrier;
			this.name = name;
		}

		@Override
		public void run() {
			try {
				Thread.sleep(2000);
				System.out.println(name + " is ready ...");
				//等待所有线程都ready就绪
				this.cyclicBarrier.await();
				//所有线程都ready就绪，同时开始running
				System.out.println(name + " is running ...");
				//等待所有线程running结束
				this.cyclicBarrier.await();
				System.out.println(name + " is run over ...");
			} catch (InterruptedException e) {
				e.printStackTrace();
			} catch (BrokenBarrierException e) {
				e.printStackTrace();
			}
		}

	}

}

```

-----
参考:
- [Java 并发编程（四）常用同步工具类](http://www.2cto.com/kf/201412/359051.html)
