### 智能合约源文件基本要素概览（Structure of a Contract）

`Solidity` 合约和面向对象语言非常相似。每个合约均能包含状态变量`State Variables`, 函数`Functions`, 函数修饰符`Function Modifiers`, 事件`Events`, 结构体类型`Struct Types` 和 枚举类型`Enum Types`。除此以外，还有比较特殊的合约叫做库`libraries`和接口`interfaces`。

- 合约类似面向对象语言中的类。
- 支持继承

#### 状态变量 State Variables

状态变量是其永远存储在合约实例中的变量。

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract SimpleStorage {
    uint storedData; // 状态变量
    // ...
}
```

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Variables {
    // 状态变量存储在区块链上
    string public text = "Hello";
    uint public num = 123;

    function doSomething() public {
        // 局部变量不保存到区块链
        uint i = 456;

        // 全局变量
        uint timestamp = block.timestamp; // 当前块的时间戳
        address sender = msg.sender; // 来访者地址
    }
}
```

详情见`类型（Types）`章节，关于所有支持的类型和变量相关的可见性（Visibility and Accessors）。

#### 函数 Functions

函数是合约实例对象的一种行为，可以通过合约实例调用函数请求其帮助我们完成我们期望的某个任务。

函数是代码的可执行单元。函数通常在合约内定义，但也可以在合约外定义。

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
contract SimpleAuction {
    function bid() public payable { // 函数、行为、方法
        // ...
    }
}

// Helper function defined outside of a contract
function helper(uint x) pure returns (uint) {
    return x * 2;
}
```

函数调用可以设置为内部（Internal）的和外部（External）的。同时对于其它合同的不同级别的可见性和访问控制(Visibility and Accessors)。具体的情况详见后面类型中关于函数的章节。

#### 函数修饰符 Modifier

修改器（modifier）可以用来轻易的改变一个函数的行为，控制函数的逻辑，比如用于在函数执行前检查某种前置条件。

修改器是一种合约属性，可以被继承，同时还可被派生的合约重写（override）；

对于一个函数可以有多个修改器限制，在函数定义的时候依次写上，并用加空格分隔，执行的时候也是依次执行。多个修改器是同时限制，也就是说必须满足所有的修改器的权限，才可以执行函数体的代码；

```
modifier 函数修改器名(参数)｛
	a++;	// 代表函数前执行的代码
	_;		// 表示被修饰的函数中的代码
	a--;	// 代表函数后执行的代码
｝
```

函数修饰符可用于以声明方式修改功能的语义。Modifier修饰符不支持重载，也就是相同的名字不可能出现两个。

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
contract Purchase {
    address public seller;
    modifier onlySeller() { // Modifier修饰符
        require(
            msg.sender == seller,
            "Only seller can call this."
        );
    }
    
    // Modifier 使用场景，当调用`abort()`函数时，会先执行`onlySeller`检查是否满足条件，满足，继续执行，不满足，发生异常，停止
    function abort() public view onlySeller { 
        // ...
    }
}
```

#### 事件 Events

事件是以太坊虚拟机(EVM)日志基础设施提供的一个便利接口。用于获取当前发生的事件。

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
contract SimpleAuction {
    event HighestBidIncreased(address bidder, uint amount); // Event
    function bid() public payable {
        // ...
        emit HighestBidIncreased(msg.sender, msg.value); // 触发 event
    }
}
```

#### 错误 Error

错误允许您为故障情况定义描述性名称和数据。错误可用于还原语句。与字符串描述相比，错误要便宜得多，并且允许您对附加数据进行编码。您可以使用 NatSpec 向用户描述错误。

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

/// Not enough funds for transfer. Requested `requested`,
/// but only `available` available.
error NotEnoughFunds(uint requested, uint available);

contract Token {
    mapping(address => uint) balances;
    function transfer(address to, uint amount) public {
        uint balance = balances[msg.sender];
        if (balance < amount)
            revert NotEnoughFunds(amount, balance);
        balances[msg.sender] -= amount;
        balances[to] += amount;
        // ...
    }
}
```

#### 结构体类型 Struct Types

结构是自定义的结构类型，可以对多个变量进行分组封装；

自定义的将几个变量组合在一起形成的类型。

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
contract Ballot {
    struct Voter { // Struct
        uint weight;
        bool voted;
        address delegate;
        uint vote;
    }
    
    struct manager{
        Voter employ;
        string title;
    }
}
```

#### 枚举 Enum Types

特殊的自定义类型，类型的所有值可枚举的情况。

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
contract Purchase {
    enum State { Created, Locked, Inactive } // Enum
}
```

#### 映射-mapping

映射是一种引用类型，存储键--值对

格式：mapping(key=>value)

在mapping中，key可以是整型、字符串等基本数据类型，但不能使用动态数组、contract、枚举、struct、以及mapping这些类型；

value的类型没有限制；

mapping不能作为参数的形参使用

#### 库 library

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
struct Data {
    mapping(uint256 => bool) flags;
}

library Set {
    // 集合 Set library

    function insert(Data storage self, uint256 value) public returns (bool) {
        if (self.flags[value]) return false;
        self.flags[value] = true;
        return true;
    }

    function remove(Data storage self, uint256 value) public returns (bool) {
        if (!self.flags[value]) return false;
        self.flags[value] = false;
        return true;
    }

    function contains(Data storage self, uint256 value)
        public
        view
        returns (bool)
    {
        return self.flags[value];
    }
}

contract C {
    Data knownValues;

    function register(uint256 value) public {
        // library 函数不需要通过实例对象调用，可直接通过 library 名字直接调用
        require(Set.insert(knownValues, value));
    }
}

```

#### 接口 Interface

接口类似于抽象协议，但是不能实现任何功能。还有其他限制：

* 它们不能继承其他合约，但是可以从其他接口继承。
* 所有声明的函数都必须是外部的。
* 接口不能声明构造函数。
* 接口不能声明状态变量。

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
interface ParentA {
    function test() external returns (uint256);
}
interface ParentB {
    function test() external returns (uint256);
}

```

