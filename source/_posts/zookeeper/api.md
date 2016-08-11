title: zooKeeper client program
date: 2015-12-14 14:40:44
categories: ZooKeeper
toc: true
---
## 概述 ##
本文所有实验基于[Apache zookeeper-3.4.6](http://zookeeper.apache.org/doc/r3.4.6/)版本。
## zkCli.sh ##

`$ZOOKEEPER_HOME/bin`目录下存在以下可执行脚本:

|	脚本	|    说明    |
|    :------ 	|   :------  |   
|	zkCleanup.sh	|	清理zookeeper历史数据，包括事务日志文件和快照数据文件   |
|	zkCli.sh	|	zookeeper客户端 |
|	zkEnv.sh	|	zookeeper环境变量设置 |
|	zkServer.sh	|	zookeeper服务启动、终止、重启脚本 |

###  启动 ###

默认情况下`sh zkCli.sh`会连接到本机zookeeper服务器.
![start-localhost](/imgs/zookeeper/1.jpg)
也可通过`sh zkCli.sh -server hostIp:port`连接到其他zookeeper服务器.

### 基本操作 ###
![start-localhost](/imgs/zookeeper/2.jpg)


## Java客户端API ##
zookeeper作为一个分布式服务框架，主要用来解决分布式数据一致性问题。其提供了多种语言的客户端API,这里主要是针对java客户端的基本操作。
maven依赖:
```xml
<dependency>
	<groupId>org.apache.zookeeper</groupId>
	<artifactId>zookeeper</artifactId>
	<version>3.4.6</version>
</dependency>
```

### 创建会话 ###
客户端可通过创建一个ZooKeeper实例来连接ZooKeeper服务器。需要注意的是该会话过程的建立是一个异步的过程，构造方法在客户端初始化之后立刻返回，此时并没有真正建立一个可用的会话，在会话周期中处于"CONNECTING"状态。当该会话真正创建完成之后，ZooKeeper服务端向对应的客户端发送一个事件通知连接建立完毕。下面是ZooKeeper提供的四种构造方法:
```java
/**
 * connectString	zookeeper服务器地址列表，格式host:port，多个服务器地址以","分隔。如"192.168.2.71:2181,192.168.2.72:2181"，同时还可指定连接根目录(Chroot)。
 *		  	如"192.168.2.71:2181,192.168.2.72:2181/test",这样该次会话的根目录都会基于"/test"进行操作。这样可以实现资源隔离
 * sessionTimeout	会话超时时间(毫秒)，在一个会话周期内，zookeeper客户端和服务器之间通过心跳检测机制来维持会话的有效性，如果在sessionTimeout时间内没有有效的心跳检测，则该次会话将会失效
 * watcher		事件通知处理器
 */
public ZooKeeper(String connectString, int sessionTimeout, Watcher watcher)

/*
 * canBeReadOnly	用于表示该次会话是否支持"Read-only"模式。默认情况下，当ZooKeeper集群中某个节点与其他大部分节点失去联系时，该机器将不再处理客户端的读写请求。但在"Read-only"模式下，该节点可以继续处理客户端读请求。
 */
public ZooKeeper(String connectString, int sessionTimeout, Watcher watcher, boolean canBeReadOnly)

/*
 * sessionId，sessionPasswd	分别代表会话id和会话密钥,通过这两个参数可以唯一确定一次客户端和服务器之间的会话，从而实现会话复用。可以通过在第一次实现会话之后获取这两个参数，再次连接时再将两个参数传递进去
 */
public ZooKeeper(String connectString, int sessionTimeout, Watcher watcher, long sessionId, byte[] sessionPasswd)
public ZooKeeper(String connectString, int sessionTimeout, Watcher watcher, long sessionId, byte[] sessionPasswd, boolean canBeReadOnly)
```

基本会话实现:
```java
/**
 * zookeeper会话实例,注意该类同时实现了Watcher接口
 * @author eagle
 * @date 2015年12月15日
 */
public class ZooKeeperSessionDemo implements Watcher{

	private static final CountDownLatch connectSignal = new CountDownLatch(1);
	private static final String CONNECT_STRING = "127.0.0.1:2181,127.0.0.1:2182,127.0.0.1:2183/simple";
	private static final int DEFAULT_SESSION_TIMEOUT = 5000;

	public static void main(String[] args) {
		simpleConnect();
	}

	/**
	 * 简单会话
	 */
	public static void simpleConnect(){
		ZooKeeper client = null;
		try {
			client = new ZooKeeper(CONNECT_STRING, DEFAULT_SESSION_TIMEOUT, new ZooKeeperSessionDemo());
			System.out.println(client.getState());
			connectSignal.await();
			System.out.println("finish connected!");
		} catch (IOException e) {
			e.printStackTrace();
		} catch (InterruptedException e) {
			e.printStackTrace();
		} finally{
			if(client != null){
				try {
					client.close();
				} catch (InterruptedException e) {
					e.printStackTrace();
				}
			}
		}
	}

	@Override
	public void process(WatchedEvent event) {

		System.out.println("Receive watched event:" + event);

		//连接建立完成
		if(KeeperState.SyncConnected == event.getState()){
			connectSignal.countDown();
		}
	}


}

```
输出:
```text
CONNECTING
Receive watched event:WatchedEvent state:SyncConnected type:None path:null
finish connected!
```

session复用测试:
```java
/**
 * 测试通过sessionId以及sessionPasswd复用会话连接
 */
public static void createConnectBySeessionId(){
	ZooKeeper client = null;
	try {
		client = new ZooKeeper(CONNECT_STRING, DEFAULT_SESSION_TIMEOUT, new ZooKeeperSessionDemo());
		connectSignal.await();

		//获取sessionId以及sessionPasswd
		long sessionId = client.getSessionId();
		byte[] sessionPasswd = client.getSessionPasswd();
		System.out.println("first connected session id:" + sessionId);

		//使用错误的sesssionId
		ZooKeeper clientWithWrongSessionId = new ZooKeeper(CONNECT_STRING, DEFAULT_SESSION_TIMEOUT, new ZooKeeperSessionDemo(), new Random().nextLong(), sessionPasswd);

		//使用正确的sessionId以及sessionPasswd
		client = new ZooKeeper(CONNECT_STRING, DEFAULT_SESSION_TIMEOUT, new ZooKeeperSessionDemo(), sessionId, sessionPasswd);
	} catch (IOException e) {
		e.printStackTrace();
	} catch (InterruptedException e) {
		e.printStackTrace();
	} finally{
		if(client != null){
			try {
				client.close();
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
	}
}
```
输出:
```text
Receive watched event:WatchedEvent state:SyncConnected type:None path:null
first connected session id:167089735794753536
Receive watched event:WatchedEvent state:Expired type:None path:null   //复用错误的sessionId，连接失败
Receive watched event:WatchedEvent state:SyncConnected type:None path:null   //复用正确的sessionId
```

### 创建节点 ###
zookeeper分别提供以下两种同步和异步的方式创建节点，同时注意临时节点是无法创建子节点的。

1. 同步方式

调用接口:
```java
/**
 * 同步方式
 * @param path	节点路径
 * @param data	节点创建之后的初始化内容
 * @param acl	节点ACL策略
 * @param createMode	枚举类型,共4种. PERSISTENT(持久节点，会话结束会继续存在)/PERSISTENT_SEQUENTIAL(持久顺序型)
 * 			EPHEMERAL（临时节点,会话结束则自动删除）/ EPHEMERAL_SEQUENTIAL(临时顺序型)
 */
public void create(final String path, byte data[], List<ACL> acl,CreateMode createMode){
```
实例:
```java
/**
 * 通过同步方式创建节点
 */
public static void createZNodeSync() throws IOException, InterruptedException, KeeperException{
	ZooKeeper client = new ZooKeeper(CONNECT_STRING, DEFAULT_SESSION_TIMEOUT, new ZooKeeperSessionDemo());
	connectSignal.await();
	String path = client.create("/s1", "s1".getBytes(), Ids.OPEN_ACL_UNSAFE, CreateMode.EPHEMERAL);
	System.out.println("finish create znode:" + path);
	path = client.create("/s1", "s1".getBytes(), Ids.OPEN_ACL_UNSAFE, CreateMode.EPHEMERAL_SEQUENTIAL);
	System.out.println("finish create znode:" + path);
}
```
输出:

```text
Receive watched event:WatchedEvent state:SyncConnected type:None path:null
finish create znode:/s1
finish create znode:/s10000000002
```
注意:以上操作均是在根目录/simple下操作(CONNECT_STRING = "127.0.0.1:2181,127.0.0.1:2182,127.0.0.1:2183/simple")。

2. 异步方式

调用接口:
```java
	/**
	 * 异步方式
	 * @param path	节点路径
	 * @param data	节点创建之后的初始化内容
	 * @param acl	节点ACL策略
	 * @param createMode	枚举类型,共4种. PERSISTENT(持久节点，会话结束会继续存在)/PERSISTENT_SEQUENTIAL(持久顺序型)
	 * 									  EPHEMERAL（临时节点,会话结束则自动删除）/ EPHEMERAL_SEQUENTIAL(临时顺序型)
	 * @param cb	注册一个回调函数。当服务器节点创建完成之后，客户端会自动调用该接口
	 * @param ctx	用于传递一个对象，可以被传递到回调方法中。通常放置一个上下文信息
	 */
	public void create(final String path, byte data[], List<ACL> acl,CreateMode createMode,  StringCallback cb, Object ctx)
```

demo:
```java
	/**
	 * 通过异步方式创建节点
	 * @throws IOException
	 * @throws InterruptedException
	 */
	public static void createZNodeAsync() throws IOException, InterruptedException {
		ZooKeeper client = new ZooKeeper(CONNECT_STRING, DEFAULT_SESSION_TIMEOUT, new ZooKeeperSessionDemo());
		connectSignal.await();

		client.create("/s1", "s1".getBytes(), Ids.OPEN_ACL_UNSAFE, CreateMode.EPHEMERAL_SEQUENTIAL, new StringCallback() {

			@Override
			public void processResult(int rc, String path, Object ctx, String name) {
				System.out.println("create path result:[rc:" + rc + ", path:" + path + ", ctx:" + ctx + ", name:" + name + "]");
			}
		}, "hello");

		//注意由于是异步创建,这里将线程sleep一会，以便打印结果
		Thread.sleep(10000);
	}
```
输出:
```text
Receive watched event:WatchedEvent state:SyncConnected type:None path:null
create path result:[rc:0, path:/s1, ctx:hello, name:/s10000000006]
```
关于StringCallback中processResult()方法的相关说明:
```java
interface StringCallback extends AsyncCallback {

	/**
	 *
	 * @param rc	服务端响应码
	 *		0(OK):调用成功.	-4(ConnectionLoss):客户端与服务端断开连接	-100(NodeExists):指定节点已经存在	-112(SessionExpired):会话已过期
	 * @param path	接口调用时传入api的数据节点的节点路径参数
	 * @param ctx	接口调用时传入api的ctx的参数值
	 * @param name	实际在服务器端创建的节点
	 */
        public void processResult(int rc, String path, Object ctx, String name);
    }
```

** 关于同步和异步接口方法的最大区别在于，节点的创建过程(包括网络通信和服务端的节点创建过程)是异步的。在异步接口中，接口本身是不会抛出异常的，所有的异常都会在回调函数中通过Result Code来体现。**

### 删除节点 ###
和创建节点一样，删除节点同样提供了同步和异步两种。注意,如果被删除的节点同时存在子节点，则该节点将无法删除，除非先删除其所有子节点。

```java
	/**
	 * 异步删除
	 * @param path		删除节点路径
	 * @param version	数据版本,zookeeper中的数据版本从0开始递增。-1表示最新数据版本
	 * @param cb		回调函数
	 * @param ctx		上下文信息
	 */
	 public void delete(final String path, int version, VoidCallback cb,Object ctx);

	/**
	 * 同步删除
	 */
	 public void delete(final String path, int version);
```
demo:
```java
	/**
	 * 通过同步方式创建节点
	 * @throws IOException
	 * @throws InterruptedException
	 * @throws KeeperException
	 */
	public static void deleteZNodeSync() throws IOException, InterruptedException, KeeperException{
		ZooKeeper client = new ZooKeeper(CONNECT_STRING, DEFAULT_SESSION_TIMEOUT, new ZooKeeperSessionDemo());
		connectSignal.await();
		String path = client.create("/s1", "s1".getBytes(), Ids.OPEN_ACL_UNSAFE, CreateMode.PERSISTENT);
		System.out.println("finish create znode:" + path);
		List<String> children = client.getChildren("/", false);
		System.out.println("children:" + children.toString());
		client.delete(path, -1);
		System.out.println("finish delete znode:" + path);
		children = client.getChildren("/", false);
		System.out.println("children:" + children.toString());
	}
```
输出:
```
Receive watched event:WatchedEvent state:SyncConnected type:None path:null
finish create znode:/s1
children:[s1]
finish delete znode:/s1
children:[]
```

### 读取数据 ###
读取数据，包括或子节点以及当前节点的数据.

1. 获取子节点

可以通过如下接口获取当前节点的子节点:

```java
public List<String> getChildren(final String path, Watcher watcher);
public List<String> getChildren(String path, boolean watch);
public void getChildren(final String path, Watcher watcher,ChildrenCallback cb, Object ctx);
public void getChildren(String path, boolean watch, ChildrenCallback cb, Object ctx);
public List<String> getChildren(final String path, Watcher watcher,Stat stat);
public List<String> getChildren(String path, boolean watch, Stat stat);
public void getChildren(final String path, Watcher watcher,Children2Callback cb, Object ctx);
public void getChildren(String path, boolean watch, Children2Callback cb,Object ctx);
```

参数说明

|	参数	|    说明    |
|    :------ 	|   :------  |   
|	path	|	节点路径   |
|	watcher|	注册Ｗatcher。一旦在本次子节点获取之后，子节点列表发生变化，那么就会通过该watcher向客户端发送通知。该参数允许为null |
|	watch	|	是否需要注册一个watcher。这里指默认watcher |
|	cb	|	异步回调函数 |
|	ctx	|	上下文信息对象 |
|	stat	|	指定数据节点的节点状态信息。用法是在接口中传入一个旧的stat变量，该stat变量会在方法执行过程中，被来自服务器响应的新的stat对象替换 |

** 需要注意的是，注册的Watcher当子节点发生变化时，服务端会向客户端发送一个NodeChildrenChanged(EventType.NodeChildrenChanged)类型的事件通知。注意，该通知中并没有包含最新的节点列表，最新的节点列表客户端必须主动重新获取。**

同步获取子节点:
```java
	/**
	 * 同步获取子节点列表
	 *
	 * @throws IOException
	 * @throws InterruptedException
	 * @throws KeeperException
	 */
	public static void getChildrenSync() throws IOException, InterruptedException, KeeperException{
		final ZooKeeper client = new ZooKeeper(CONNECT_STRING, DEFAULT_SESSION_TIMEOUT, new ZooKeeperSessionDemo());
		connectSignal.await();

		//获取子节点,注意这里的"/"即"/simple"，连接时由CONNECT_STRING指定"127.0.0.1:2181,127.0.0.1:2182,127.0.0.1:2183/simple";
		client.getChildren("/", new Watcher(){

			@Override
			public void process(WatchedEvent event) {
				if(EventType.NodeChildrenChanged == event.getType()){
					try {
							System.out.println("receive node changed event. reload children:" +  client.getChildren(event.getPath(), true));
						} catch (KeeperException e) {
							e.printStackTrace();
						} catch (InterruptedException e) {
							e.printStackTrace();
						}
				}
			}

		});

		//创建子节点/simple/s1
		String path = client.create("/s1", "s1".getBytes(), Ids.OPEN_ACL_UNSAFE, CreateMode.EPHEMERAL);
		System.out.println("finish create znode:" + path);

		path = client.create("/s2", "s2".getBytes(), Ids.OPEN_ACL_UNSAFE, CreateMode.EPHEMERAL);
		System.out.println("finish create znode:" + path);

	}
```

输出:
```
finish create znode:/s1
receive node changed event. reload children:[s1]
finish create znode:/s2
```
** 注:由上面输出可以看出,在创建子节点/s1时，触发了node changed事件。但是在创建/s2时并没有触发该事件，这是由于getChildren()中的Watcher一旦触发一次之后就失效了，需要客户端自己再重新注册!**

异步:
```java
	/**
	 * 异步获取子节点列表
	 *
	 * @throws IOException
	 * @throws InterruptedException
	 * @throws KeeperException
	 */
	public static void getChildrenAsync() throws IOException, InterruptedException, KeeperException{
		final ZooKeeper client = new ZooKeeper(CONNECT_STRING, DEFAULT_SESSION_TIMEOUT, new ZooKeeperSessionDemo());
		connectSignal.await();

		//创建子节点/simple/s1
		String path = client.create("/s1", "s1".getBytes(), Ids.OPEN_ACL_UNSAFE, CreateMode.EPHEMERAL);
		System.out.println("finish create znode:" + path);

		//获取子节点,注意这里的"/"即"/simple"，连接时由CONNECT_STRING指定"127.0.0.1:2181,127.0.0.1:2182,127.0.0.1:2183/simple";
		client.getChildren("/", true, new AsyncCallback.Children2Callback(){

					@Override
					public void processResult(int rc, String path, Object ctx, List<String> children, Stat stat) {
						System.out.println("async get children:[response code:" + rc + ", path:" + path + ", ctx:" + ctx + ", children:" + children.toString() + ", stat:" + stat + "]");
					}

				}, "hello");

		path = client.create("/s2", "s2".getBytes(), Ids.OPEN_ACL_UNSAFE, CreateMode.EPHEMERAL);
		System.out.println("finish create znode:" + path);

		Thread.sleep(10000);
	}

```
输出:
```
finish create znode:/s1
async get children:[response code:0, path:/, ctx:hello, children:[s1], stat:25769803785,25769803785,1450153810191,1450153810191,0,59,0,0,11,1,25769803877]
finish create znode:/s2
```

2. getData

getData()接口和getChildren()接口参数意义基本相同.当节点数据发生变化时,服务端会发送ＮodeDataChanged通知.

同步方式:
```java
public class ZooKeeperGetDataDemo implements Watcher {

	private static final CountDownLatch connectSignal = new CountDownLatch(1);
	private static final String CONNECT_STRING = "127.0.0.1:2181,127.0.0.1:2182,127.0.0.1:2183/simple";
	private static final int DEFAULT_SESSION_TIMEOUT = 5000;

	private static ZooKeeper client;
	private static Stat stat = new Stat();

	public static void main(String[] args) throws KeeperException, InterruptedException{
		client = initClient();

		//创建"/simple/test1"
		String path = client.create("/test1", "test1".getBytes(), Ids.OPEN_ACL_UNSAFE, CreateMode.EPHEMERAL);
		System.out.println("success create path:" + path);

		//获取数据,注册Watcher
		String data = new String(client.getData(path, new ZooKeeperGetDataDemo(), stat));
		System.out.println("data:" + data);
		System.out.println("stat:" + stat.getCzxid() + "," + stat.getMzxid() + "," + stat.getVersion());

		//更新数据,-1指当前数据的最新版本
		client.setData(path, "test2".getBytes(), -1);
	}

	public static ZooKeeper initClient() {
		ZooKeeper client = null;
		try {
			client = new ZooKeeper(CONNECT_STRING, DEFAULT_SESSION_TIMEOUT,new ZooKeeperGetDataDemo());
			connectSignal.await();
			System.out.println("finish connected!");
		} catch (IOException e) {
			e.printStackTrace();
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
		return client;
	}

	@Override
	public void process(WatchedEvent event) {
		if(KeeperState.SyncConnected == event.getState()){
			if(EventType.None == event.getType() && event.getPath() == null){
				connectSignal.countDown();
			}else if(EventType.NodeDataChanged == event.getType()){
				try {
					System.out.println("process data:" + new String(client.getData(event.getPath(), true, stat)));
					System.out.println("process stat:" + stat.getCzxid() + "," + stat.getMzxid() + "," + stat.getVersion());
				} catch (KeeperException e) {
					e.printStackTrace();
				} catch (InterruptedException e) {
					e.printStackTrace();
				}
			}
		}
	}


}

```
输出:
```
finish connected!
success create path:/test1
data:test1
stat:25769803885,25769803885,0
process data:test2
process stat:25769803885,25769803886,1
```
** 注意NodeDataChanged触发条件是节点数据内容变化或数据版本变更,同时注意其中Stat使用方式 **

### 数据更新 ###
数据更新接口:
```java
public Stat setData(final String path, byte data[], int version);
/**
 *
 * @param path
 * @param data
 * @param version	指定数据版本即本次数据变更针对的版本
 * @param cb
 * @param ctx
 */
public void setData(final String path, byte data[], int version,StatCallback cb, Object ctx);
```

** 关于数据版本,zookeeper每个节点都有数据版本的概念,在调用更新操作的时候可以添加version参数,该参数对应于"CAS"原理中的"预期值",表明是针对该数据版本进行更新的.也就是说,当一个客户端试图进行更新操作,它会携带上次获取到的version值进行更新.而如果在这段时间内,zookeeper服务器上该节点数据恰好已经被其他客户端更新了,那么其数据版本一定也会发生变化,因此会与客户端携带的version无法匹配,于是便会更新失败.这样可以有效的避免一些分布式更新的并发问题.而zookeeper客户端就可以利用该特性构建更复杂的应用场景如分布式锁服务等. **

### 权限控制 ###
使用方式:
```java
/**
 * scheme zookeeper分别提供了world, auth, digest, ip以及super等几种
 */
public void addAuthInfo(String scheme, byte auth[])
```

```java
public class ZooKeeperACLDemo implements Watcher{

	private static CountDownLatch connectSignal = new CountDownLatch(1);
	private static final String CONNECT_STRING = "127.0.0.1:2181,127.0.0.1:2182,127.0.0.1:2183/simple";
	private static final int DEFAULT_SESSION_TIMEOUT = 5000;

	public static void main(String[] args) throws KeeperException, InterruptedException {

		//1.使用带有权限认证的客户端创建节点"/acl-test"
		ZooKeeper client = initClient();
		//附加权限认证
		client.addAuthInfo("digest", "eagle:eagle".getBytes());
		//创建节点"/simple/acl-test"
		String path = client.create("/acl-test2", "/acl-test2".getBytes(), Ids.CREATOR_ALL_ACL, CreateMode.PERSISTENT);
		System.out.println("success create znode:" + path + " with auth info!");
		//关闭连接
		client.close();
		connectSignal = new CountDownLatch(1);

		//2.使用没有权限认证的客户端,创建子节点"/acl-test/test1"
		client = initClient();

		try{
			client.create(path + "/test2", "/acl-test2/test2".getBytes(), Ids.OPEN_ACL_UNSAFE, CreateMode.PERSISTENT);
		} catch(Throwable e){
			System.err.println("failed create " + (path + "/test2 without auth info, caused by:") +  e.getMessage());
		}

		//3.添加权限认证,创建子节点"/acl-test/test1"
		client.addAuthInfo("digest", "eagle:eagle".getBytes());
		try{
			path = client.create(path + "/test2", "/acl-test2/test2".getBytes(), Ids.OPEN_ACL_UNSAFE, CreateMode.PERSISTENT);
			System.out.println("success create with auth info for path:" + path);
		} catch(Throwable e){
			System.err.println(e.getMessage());
		}


		client.close();
		connectSignal = new CountDownLatch(1);
		client = initClient();

		//4.使用无权限认证的客户端删除"/simple/acl-test/test1"
		try{
			client.delete("/acl-test2/test2", -1);
			System.out.println("success delete path:/acl-test2/test2 without auth info!");
		}catch(Throwable e){
			System.err.println("failed delete path:/acl-test2/test2 without auth info!");
		}

		//5.使用有权限认证的客户端删除"/simple/acl-test/test1"
		client.addAuthInfo("digest", "eagle:eagle".getBytes());
		try{
			client.delete("/acl-test2/test2", -1);
			System.out.println("success delete path:/acl-test2/test2 with auth info!");
		}catch(Throwable e){
			e.printStackTrace();
		}

		//6.使用无权限认证的客户端删除"/simple/acl-test"
		client.close();
		connectSignal = new CountDownLatch(1);
		client = initClient();

		try{
			client.delete("/acl-test2", -1);
			System.out.println("success delete path:/acl-test2 without auth info!");
		}catch(Throwable e){
			e.printStackTrace();
		}
	}

	public static ZooKeeper initClient() {
		ZooKeeper client = null;
		try {
			client = new ZooKeeper(CONNECT_STRING, DEFAULT_SESSION_TIMEOUT,new ZooKeeperACLDemo());
			connectSignal.await();
			System.out.println("finish connected!");
		} catch (IOException e) {
			e.printStackTrace();
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
		return client;
	}

	@Override
	public void process(WatchedEvent event) {
		if(KeeperState.SyncConnected == event.getState()){
			connectSignal.countDown();
		}
	}

}

```
输出:
```
finish connected!
success create znode:/acl-test2 with auth info!
finish connected!
failed create /acl-test2/test2 without auth info, caused by:KeeperErrorCode = NoAuth for /acl-test2/test2
success create with auth info for path:/acl-test2/test2
finish connected!
failed delete path:/acl-test2/test2 without auth info!
success delete path:/acl-test2/test2 with auth info!
finish connected!
success delete path:/acl-test2 without auth info!
```

** 值得注意的是在前面6中的操作是成功的,也就是说对一个节点添加权限之后,对于其删除权限作用范围是其子节点,当这个节点的所有子节点均被删除之后,该节点依然可以被没有认证信息的客户端删除 **

## 开源客户端Curator ##

### 简介 ###
Curator是Netflix开源的一套ZooKeeper客户端框架.和ZkClient一样,Curator解决了很多zookeeper客户端非常底层的细节开发工作,包括连接重连,反复注册Watcher和NodeExistsException异常等,目前已成为Apache顶级项目.详细介绍可参考[Zookeeper开源客户端框架Curator简介](http://macrochen.iteye.com/blog/1366136).

maven依赖:
```xml
<dependency>
	<groupId>org.apache.curator</groupId>
	<artifactId>curator-framework</artifactId>
	<version>2.7.1</version>
</dependency>
```

### 简单实例 ###

```java
/**
 * zookeeper开源客户端框架Curator测试
 * @author eagle
 * @date 2015年12月15日
 */
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


	public static void main(String[] args) {
		CuratorFramework client = initClient();
		String destPath = "/curator-test/test1";
		createData(client, destPath);
		deleteData(client, destPath);
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
	 * 创建节点
	 * @param client
	 * @param destPath
	 */
	private static void createData(CuratorFramework client, String destPath){
		try {
			//创建节点时,如果父节点不存在,则一起被创建
			String path = client.create().creatingParentsIfNeeded().withMode(CreateMode.PERSISTENT).forPath(destPath);
			System.out.println("finish create path:" + path);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * 删除节点
	 * @param client
	 * @param destPath
	 */
	private static void deleteData(CuratorFramework client, String destPath){
		try {
			//删除一个节点,强制保证删除
			client.delete().guaranteed().forPath(destPath);
			System.out.println("success delete path:" + destPath);
			createData(client, destPath);
			//删除一个节点,强制并递归删除所有子节点
			client.delete().deletingChildrenIfNeeded().forPath("/curator-test");
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

}
```

---

参考:
* [从Paxos到Zookeeper：分布式一致性原理与实践](http://www.broadview.com.cn/#book/bookdetail/bookDetailAll.jsp?book_id=12ccd70f-a944-11e4-9c0a-005056c00008&isbn=978-7-121-24967-9)
