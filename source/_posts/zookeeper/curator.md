title: curator apply
date: 2015-12-14 14:40:44
categories: ZooKeeper
toc: true
---

本文所有实验基于[Apache zookeeper-3.4.6](http://zookeeper.apache.org/doc/r3.4.6/)版本, Curator版本2.7.1.
## 事件监听 ##
zookeeper原生支持通过注册Watcher来进行事件监听,但是其使用比较麻烦,需要开发人员自己反复注册Watcher.Curator引入Cache来实现对zookeeper服务器端事件的监听.Cache是Curator中对事件监听的包装,其对事件的监听可以近似看作是一个本地缓存视图和远程zookeeper视图的对比过程.同时curator能够自动为开发人员处理反复注册监听.Cache分为两种监听类型: 节点监听和子节点监听.

### 节点监听 ###

```java
public class Main {

	/**
	 * 初始sleep时间(毫秒)
	 */
	private static final int BASE_SLEEP_TIME = 1000;
	/**
	 * 最大重试次数
	 */
	private static final int MAX_RETRIES_COUNT = 5;
	/**
	 * 最大sleep时间
	 */
	private static final int MAX_SLEEP_TIME = 60000;

	private static final String CONNECT_STRING = "127.0.0.1:2181,127.0.0.1:2182,127.0.0.1:2183";
	private static final int SESSION_TIMEOUT = 5000;
	private static final int CONNECTION_TIMEOUT = 5000;


	public static void main(String[] args) throws Exception {
		CuratorFramework client = initClient();
		watchDataChanged(client);
	}

	/**
	 * 初始化客户端
	 * @return
	 */
	private static CuratorFramework initClient() {
		//1.设置重试策略,重试时间计算策略sleepMs = baseSleepTimeMs * Math.max(1, random.nextInt(1 << (retryCount + 1)));
		RetryPolicy retryPolicy = new ExponentialBackoffRetry(BASE_SLEEP_TIME, MAX_RETRIES_COUNT, MAX_SLEEP_TIME);

		//2.使用Fluent风格初始化客户端
		CuratorFramework client = CuratorFrameworkFactory.builder()
									.connectString(CONNECT_STRING)
									.sessionTimeoutMs(SESSION_TIMEOUT)
									.connectionTimeoutMs(CONNECTION_TIMEOUT)
									.retryPolicy(retryPolicy)
									.namespace("simple")		//命名空间隔离
									.build();
		client.start();
		return client;
	}

	/**
	 * 监听节点数据变化
	 * @throws Exception
	 */
	private static void watchDataChanged(CuratorFramework client) throws Exception{
		//1.创建目标监听节点
		String path = client.create().creatingParentsIfNeeded().forPath("/node1", "eagle".getBytes());
		System.out.println("success create path:" + path);

		//2.添加监听器
		final NodeCache nodeCache = new NodeCache(client, path);
		nodeCache.getListenable().addListener(new NodeCacheListener() {

			@Override
			public void nodeChanged() throws Exception {
				System.out.println("node data changed, new data:" + new String(nodeCache.getCurrentData().getData()));
			}
		});
		nodeCache.start(true);

		//3.更新数据
		client.setData().forPath(path, "eagle_update".getBytes());
		Thread.sleep(1000);

		//4.再次更新
		client.setData().forPath(path, "eagle_update_update".getBytes());
		Thread.sleep(1000);

		//4.删除节点
		client.delete().deletingChildrenIfNeeded().forPath(path);
	}
}
```
输出:
```
success create path:/node1
node data changed, new data:eagle_update
node data changed, new data:eagle_update_update
```

注:
	1. NodeCache.start(boolean buildInitial)方法中buildInitial参数默认为false,如果设置为true,那么NodeCache在第一次启动时就立刻从zookeeper上读取对应节点的数据内容,并保存在Cache中.
	2. NodeCache不仅可以用于监听节点的内容变更,也能监听指定节点是否存在.如果原本节点不存在,那么Cache就会在节点被创建后触发NodeCacheListener.但,如果该数据节点被删除,那么Curator就无法触发该事件.

### 子节点监听 ###

```java
public class Main {

	/**
	 * 初始sleep时间(毫秒)
	 */
	private static final int BASE_SLEEP_TIME = 1000;
	/**
	 * 最大重试次数
	 */
	private static final int MAX_RETRIES_COUNT = 5;
	/**
	 * 最大sleep时间
	 */
	private static final int MAX_SLEEP_TIME = 60000;

	private static final String CONNECT_STRING = "127.0.0.1:2181,127.0.0.1:2182,127.0.0.1:2183";
	private static final int SESSION_TIMEOUT = 5000;
	private static final int CONNECTION_TIMEOUT = 5000;


	public static void main(String[] args) throws Exception {
		CuratorFramework client = initClient();
		watchChildrenChanged(client);
	}

	/**
	 * 初始化客户端
	 * @return
	 */
	private static CuratorFramework initClient() {
		//1.设置重试策略,重试时间计算策略sleepMs = baseSleepTimeMs * Math.max(1, random.nextInt(1 << (retryCount + 1)));
		RetryPolicy retryPolicy = new ExponentialBackoffRetry(BASE_SLEEP_TIME, MAX_RETRIES_COUNT, MAX_SLEEP_TIME);

		//2.使用Fluent风格初始化客户端
		CuratorFramework client = CuratorFrameworkFactory.builder()
														 .connectString(CONNECT_STRING)
														 .sessionTimeoutMs(SESSION_TIMEOUT)
														 .connectionTimeoutMs(CONNECTION_TIMEOUT)
														 .retryPolicy(retryPolicy)
														 .namespace("simple")		//命名空间隔离
														 .build();
		client.start();
		return client;
	}

	private static void watchChildrenChanged(CuratorFramework client) throws Exception{
		//1.创建目标监听节点
		String path = client.create().creatingParentsIfNeeded().forPath("/node1", "eagle".getBytes());
		System.out.println("success create path:" + path);

		//2.添加监听器
		PathChildrenCache cache = new PathChildrenCache(client, path, true);
		cache.start(StartMode.BUILD_INITIAL_CACHE);
		cache.getListenable().addListener(new PathChildrenCacheListener() {

			@Override
			public void childEvent(CuratorFramework client, PathChildrenCacheEvent event) throws Exception {
				switch(event.getType()){
					case  CHILD_ADDED:
						System.out.println("CHILD_ADDED:" + event.getData().getPath());
						break;
					case CHILD_REMOVED:
						System.out.println("CHILD_REMOVED:" + event.getData().getPath());
						break;
					case CHILD_UPDATED:
						System.out.println("CHILD_UPDATED:" + event.getData().getPath());
						break;
					default:
						System.out.println("event type:" + event.getType());
						break;
				}
			}
		});

		//3.创建子节点
		String result = client.create().creatingParentsIfNeeded().withMode(CreateMode.PERSISTENT).forPath(path + "/c1");
		System.out.println("success create path:" + result);

		Thread.sleep(2000);

		//4.创建二级子节点
		String result2 = client.create().creatingParentsIfNeeded().withMode(CreateMode.PERSISTENT).forPath(result + "/c2");
		System.out.println("success create path:" + result2);

		Thread.sleep(2000);

		//5.删除子节点
		client.delete().deletingChildrenIfNeeded().forPath(result);
		System.out.println("success delete path:" + result);

		Thread.sleep(2000);

		//6.删除节点
		client.delete().forPath(path);
		System.out.println("success delete path:" + path);

		Thread.sleep(2000);

		cache.close();
	}
}
```

输出:
```text
success create path:/node1
success create path:/node1/c1
CHILD_ADDED:/node1/c1
success create path:/node1/c1/c2
CHILD_REMOVED:/node1/c1
success delete path:/node1/c1
success delete path:/node1
```

** 由前面结果可以看出子节点监听,只对一级子节点的变更有效.当创建/node1/c1/c2时并未触发通知.同时,被检测的节点数据变更也不触发通知 **

## Master选举 ##
通过zookeeper实现master选择思路: 选择一个根节点如/master_select,多台机器同时向该节点创建一个子节点/master_select/lock,利用zookeeper的特性,最终只有一台机器能够创建成功,成功的那台机器就作为Master.

Curator也是基于此思路,但是其将节点创建,事件监听和自动选举进行了封装.

多线程模拟Master选举:
```java
public class MasterSelectedDemo {

	private static final int BASE_SLEEP_TIME = 1000;
	private static final int MAX_RETRIES_COUNT = 5;
	private static final int MAX_SLEEP_TIME = 60000;

	private static final String CONNECT_STRING = "127.0.0.1:2181,127.0.0.1:2182,127.0.0.1:2183";
	private static final int SESSION_TIMEOUT = 5000;
	private static final int CONNECTION_TIMEOUT = 5000;

	private static final String MASTER_PATH = "/master_lock";

	public static void main(String[] args) throws Exception {

		final CuratorFramework client = initClient();

		ExecutorService executorService = Executors.newFixedThreadPool(10);

		for(int i = 0; i < 8; i++){
			executorService.execute(new Runnable() {

				@Override
				public void run() {
					while(true) {

						LeaderSelector leaderSelector = new LeaderSelector(client, MASTER_PATH, new LeaderSelectorListenerAdapter() {

							/**
							 * Curator会在该线程被成功选取为master时回调该方法.同时,当该方法执行完毕之后,Curator会自动释放master权利,然后重新开始新一轮的选举
							 */
							@Override
							public void takeLeadership(CuratorFramework client) throws Exception {
								System.out.println("Thread:" + Thread.currentThread().getId() + " be selected as Master!");
								try{
									Thread.sleep(3000);
								}catch(Throwable e){

								}
								System.out.println("Thread:" + Thread.currentThread().getName() + " release master right!");
							}
						});

						//By default, when LeaderSelectorListener.takeLeadership(CuratorFramework) returns, this instance is not requeued.
						//Calling this method puts the leader selector into a mode where it will always requeue itself.
						leaderSelector.autoRequeue();

						//Attempt leadership. This attempt is done in the background - i.e. this method returns immediately.
						leaderSelector.start();

						try {
							Thread.sleep(3000);
						} catch (InterruptedException e) {
							e.printStackTrace();
						}

						//Shutdown this selector and remove yourself from the leadership group
						leaderSelector.close();
					}
				};
			});
		}

		executorService.shutdown();

		Thread.sleep(30000);
	}

	/**
	 * 初始化客户端
	 * @return
	 */
	private static CuratorFramework initClient() {
		//1.设置重试策略,重试时间计算策略sleepMs = baseSleepTimeMs * Math.max(1, random.nextInt(1 << (retryCount + 1)));
		RetryPolicy retryPolicy = new ExponentialBackoffRetry(BASE_SLEEP_TIME, MAX_RETRIES_COUNT, MAX_SLEEP_TIME);

		//2.使用Fluent风格初始化客户端
		CuratorFramework client = CuratorFrameworkFactory.builder()
									.connectString(CONNECT_STRING)
									.sessionTimeoutMs(SESSION_TIMEOUT)
									.connectionTimeoutMs(CONNECTION_TIMEOUT)
									.retryPolicy(retryPolicy)
									.namespace("simple")		//命名空间隔离
									.build();
		client.start();
		return client;
	}

}

```

输出:

```
Thread:24 be selected as Master!
Thread:Curator-LeaderSelector-3 release master right!
Thread:30 be selected as Master!
Thread:Curator-LeaderSelector-10 release master right!
Thread:37 be selected as Master!
Thread:Curator-LeaderSelector-16 release master right!
Thread:45 be selected as Master!
Thread:Curator-LeaderSelector-24 release master right!
Thread:53 be selected as Master!
Thread:Curator-LeaderSelector-32 release master right!
Thread:62 be selected as Master!
```

## 分布式锁 ##
[跟着实例学习ZooKeeper的用法：分布式锁](http://ifeve.com/zookeeper-lock/)

```java
/**
 * curator分布式锁
 * @author eagle
 * @date 2015年12月16日
 */
public class CuratorLock {

	private static final int BASE_SLEEP_TIME = 1000;
	private static final int MAX_RETRIES_COUNT = 5;
	private static final int MAX_SLEEP_TIME = 60000;

	private static final String CONNECT_STRING = "127.0.0.1:2181,127.0.0.1:2182,127.0.0.1:2183";
	private static final int SESSION_TIMEOUT = 5000;
	private static final int CONNECTION_TIMEOUT = 5000;

	private static final String MASTER_PATH = "/master_lock";

	public static void main(String[] args) {

		final CountDownLatch countDownLatch = new CountDownLatch(1);
		CuratorFramework client = initClient();

		final InterProcessLock lock = new InterProcessMutex(client, MASTER_PATH);

		for(int i = 0; i < 10; i++){
			new Thread(new Runnable() {

				@Override
				public void run() {
					try {
						countDownLatch.await();
						lock.acquire();
					} catch (InterruptedException e) {
						e.printStackTrace();
					} catch (Exception e) {
						e.printStackTrace();
					}

					SimpleDateFormat format = new SimpleDateFormat("HH:mm:ss|SSS");
					String date = format.format(new Date());
					System.out.println("generate number:" + date);

					try {
						lock.release();
					} catch (Exception e) {
						e.printStackTrace();
					}
				}
			}).start();
		}

		countDownLatch.countDown();
	}


	/**
	 * 初始化客户端
	 * @return
	 */
	private static CuratorFramework initClient() {
		//1.设置重试策略,重试时间计算策略sleepMs = baseSleepTimeMs * Math.max(1, random.nextInt(1 << (retryCount + 1)));
		RetryPolicy retryPolicy = new ExponentialBackoffRetry(BASE_SLEEP_TIME, MAX_RETRIES_COUNT, MAX_SLEEP_TIME);

		//2.使用Fluent风格初始化客户端
		CuratorFramework client = CuratorFrameworkFactory.builder()
									.connectString(CONNECT_STRING)
									.sessionTimeoutMs(SESSION_TIMEOUT)
									.connectionTimeoutMs(CONNECTION_TIMEOUT)
									.retryPolicy(retryPolicy)
									.namespace("simple")		//命名空间隔离
									.build();
		client.start();
		return client;
	}


}

```

## 分布式计数器 ##
zookeeper分布式计数器实现思路: 指定一个zookeeper数据节点作为计数器，多个应用实例在分布式锁的控制下，通过更新该数据节点的内容来实现计数功能。

```java
private static void distributedCounter(CuratorFramework client){
	DistributedAtomicInteger counter = new DistributedAtomicInteger(client, MASTER_PATH, new RetryNTimes(3, 1000));
	try {
		AtomicValue<Integer> result = counter.add(10);
		System.out.println("update:" + result.succeeded());
	} catch (Exception e) {
		e.printStackTrace();
	}
}
```

## 分布式Barrier ##

```java
public class CuratorLock {

	private static final int BASE_SLEEP_TIME = 1000;
	private static final int MAX_RETRIES_COUNT = 5;
	private static final int MAX_SLEEP_TIME = 60000;

	private static final String CONNECT_STRING = "127.0.0.1:2181,127.0.0.1:2182,127.0.0.1:2183";
	private static final int SESSION_TIMEOUT = 5000;
	private static final int CONNECTION_TIMEOUT = 5000;

	private static final String MASTER_PATH = "/master_lock";

	private static  DistributedBarrier barrier;

	public static void main(String[] args) throws Exception {

		distributedBarrier2();
	}

	private static void distributedBarrier2(){
		for(int i = 0; i < 10; i++){
			new Thread(new Runnable() {

				@Override
				public void run() {
					//1.设置重试策略,重试时间计算策略sleepMs = baseSleepTimeMs * Math.max(1, random.nextInt(1 << (retryCount + 1)));
					RetryPolicy retryPolicy = new ExponentialBackoffRetry(BASE_SLEEP_TIME, MAX_RETRIES_COUNT, MAX_SLEEP_TIME);

					//2.使用Fluent风格初始化客户端
					CuratorFramework client = CuratorFrameworkFactory.builder()
											.connectString(CONNECT_STRING)
											.sessionTimeoutMs(SESSION_TIMEOUT)
											.connectionTimeoutMs(CONNECTION_TIMEOUT)
											.retryPolicy(retryPolicy)
											.namespace("simple")		//命名空间隔离
											.build();
					client.start();

					//可以指定成员个数
					DistributedDoubleBarrier doubleBarrier = new DistributedDoubleBarrier(client, MASTER_PATH, 10);
					try {
						Thread.sleep(2000);
					} catch (InterruptedException e1) {
						// TODO Auto-generated catch block
						e1.printStackTrace();
					}
					System.out.println(Thread.currentThread().getName() + ": ready!");

					try {
						doubleBarrier.enter();
						System.out.println(Thread.currentThread().getName() + ": run!");
						Thread.currentThread().sleep(3000);
						doubleBarrier.leave();
						System.out.println(Thread.currentThread().getName() + ": exit!");
					} catch (Exception e) {
						e.printStackTrace();
					}
				}
			}).start();
		}
	}

	private static void distributedBarrier() throws Exception{

		for(int i = 0; i < 10; i++){
			new Thread(new Runnable() {

				@Override
				public void run() {
					//1.设置重试策略,重试时间计算策略sleepMs = baseSleepTimeMs * Math.max(1, random.nextInt(1 << (retryCount + 1)));
					RetryPolicy retryPolicy = new ExponentialBackoffRetry(BASE_SLEEP_TIME, MAX_RETRIES_COUNT, MAX_SLEEP_TIME);

					//2.使用Fluent风格初始化客户端
					CuratorFramework client = CuratorFrameworkFactory.builder()
											.connectString(CONNECT_STRING)
											.sessionTimeoutMs(SESSION_TIMEOUT)
											.connectionTimeoutMs(CONNECTION_TIMEOUT)
											.retryPolicy(retryPolicy)
											.namespace("simple")		//命名空间隔离
											.build();
					client.start();

				       barrier = new DistributedBarrier(client, MASTER_PATH);

					System.out.println(Thread.currentThread().getName() + ": ready!");
					try {
						barrier.setBarrier();
						//Blocks until the barrier node comes into existence
						barrier.waitOnBarrier();
						System.out.println(Thread.currentThread().getName() + ": run!");
					} catch (Exception e) {
						e.printStackTrace();
					}

				}
			}).start();

		}
		Thread.sleep(3000);
		barrier.removeBarrier();
	}
}
```

---

参考:
* [从Paxos到Zookeeper：分布式一致性原理与实践](http://www.broadview.com.cn/#book/bookdetail/bookDetailAll.jsp?book_id=12ccd70f-a944-11e4-9c0a-005056c00008&isbn=978-7-121-24967-9)
