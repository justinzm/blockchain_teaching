### 事件(Event)

事件是智能合约发出的信号。智能合约的前端UI，例如，DApps、web.js，或者任何与Ethereum JSON-RPC API连接的东西，都可以侦听这些事件。事件可以被索引，以便以后可以搜索事件记录。

> 事件在区块链中的存储
>
> 区块链是一个区块链表，这些块的内容基本上是交易记录。每个交易都有一个附加的交易日志，事件结果存放在交易日志里。合约发出的事件，可以使用合约地址访问。

Solidity中，要定义事件，可以使用 **event**关键字(在用法上类似于 **function**关键字)。然后可以在函数中使用 **emit**关键字触发事件。

```
// 声明一个事件
event Deposit(address indexed _from, bytes32 indexed _id, uint _value);
// 触发事件
emit Deposit(msg.sender, _id, msg.value);
```

创建合约并发出一个事件。

```
pragma solidity ^0.8.17;

contract Counter {
    uint256 public count = 0;
    event Increment(address who);   // 声明事件
    function increment() public {
        emit Increment(msg.sender); // 触发事件
        count += 1;
    }
}
```

上面的代码中,

* **event Increment(address who)** 声明一个合约级事件，该事件接受一个address类型的参数，该参数是执行**increment**操作的账户地址。

* **emit Increment(msg.sender)** 触发事件，事件会记入区块链中。

按照惯例，事件名称以大写字母开头，以区别于函数。

#### 用JavaScript监听事件

下面的JavaScript代码侦听 **Increment**事件，并更新UI。

```
counter = web3.eth.contract(abi).at(address);
counter.Increment(function (err, result) {
  if (err) {
    return error(err);
  }
  log("Count was incremented by address: " + result.args.who);
  getCount();
});
getCount();
```

**contract.Increment(...)** 开始侦听递增事件，并使用回调函数对其进行参数化。**getCount()** 是一个获取最新计数并更新UI的函数。

#### 索引(indexed)参数

一个事件最多有3个参数可以标记为索引。可以使用索引参数有效地过滤事件。下面的代码增强了前面的示例，来跟踪多个计数器，每个计数器由一个数字ID标识:

```
pragma solidity ^0.8.17;

contract Multicounter {
    mapping (uint256 => uint256) public counts;
    event Increment(uint256 indexed which, address who);
    function increment(uint256 which) public {
        emit Increment(which, msg.sender);
        counts[which] += 1;
    }
}
```

- **counts**替换**count**，**counts**是一个map。
- **event Increment(uint256 indexed which, address who)** 添加一个索引参数，该参数表示哪个计数器。
- **emit Increment(which, msg.sender)** 用2个参数记录事件。

在Javascript中，可以使用索引访问计数器：

```
... 
counter.Increment({ which: counterId }, function (err, result) {
  if (err) {
    return error(err);
  }
  log("Counter " + result.args.which + " was incremented by address: "
      + result.args.who);
  getCount();
});
...
```

#### 事件的局限

事件构建在Ethereum中，底层的日志接口之上。虽然您通常不会直接处理日志消息，但是了解它们的限制非常重要。

日志结构最多有4个“主题”和一个“数据”字段。第一个主题用于存储事件签名的哈希值，这样就只剩下三个主题用于索引参数。主题需要32字节长，因此，如果使用数组作为索引参数(包括类型string和bytes)，那么首先将哈希值转换为32字节。非索引参数存储在数据字段中，没有大小限制。

日志，包括记录在日志中的事件，不能从Ethereum虚拟机(EVM)中访问。这意味着合约不能读取自己的或其他合约的日志及事件。

#### 总结

Solidity 提供了一种记录交易期间事件的方法。

智能合约前端(DApp)可以监听这些事件。

索引(indexed)参数为过滤事件提供了一种高效的方法。

事件受其构建基础日志机制的限制。