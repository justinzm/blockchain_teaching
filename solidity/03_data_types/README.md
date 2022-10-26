由于Solidity是一个静态类型的语言，所以编译时需明确指定变量的类型（包括`本地变量`或`状态变量`），`Solidity`编程语言提供了一些`基本类型(elementary types)`可以用来组合成复杂类型。

Solidity 中不存在“未定义”或“空”值的概念，但新声明的变量始终具有取决于其类型的默认值。要处理任何意外值，您应该使用revert 函数来恢复整个事务，或者返回一个带有第二个bool值的元组，表示成功。

### 值类型 Value Type

以下类型也称为值类型，因为这些类型的变量总是按值传递，即当它们用作函数参数或赋值时，它们总是被复制。（为什么会叫`值类型`，是因为上述这些类型在传值时，总是值传递。比如在函数传参数时，或进行变量赋值时。）

#### 布尔型 Booleans

bool: 可能的值是常数值`true`和`false`。

运算符：

- !（逻辑否定）
- &&（逻辑连接，“和”）
- ||（逻辑析取，“或”）
- ==（等于）
- !=（不等于）

备注：运算符`&&`和`||`是短路运算符，如`f(x)||g(y)`，当`f(x)`为真时，则不会继续执行`g(y)`。

#### 整数 Integer

int / uint：各种大小的有符号和无符号不同位数的整型变量。关键字uint8 到 uint256（无符号 从8位 到 256 位 以及 int8 到 int256，以 `8` 位为步长递增。 `uint` 和 `int` 分别是 `uint256` 和 `int256` 的别名。

运算符：

- 比较运算符： `<=` ， `<` ， `==` ， `!=` ， `>=` ， `>` （返回布尔值）
- 位运算符： `&` ， `|` ， `^` （异或）， `~` （位取反）
- 移位运算符： `<<` （左移位） ， `>>` （右移位）
- 算数运算符： `+` ， `-` ， 一元运算负 `-` （仅针对有符号整型）， `*` ， `/` ， `%` （取余或叫模运算） ， `**` （幂）

对于整形 `X`，可以使用 `type(X).min` 和 `type(X).max` 去获取这个类型的最小值与最大值。

#### 地址类型 Address

地址类型有两种形式，他们大致相同：

> - address：保存一个20字节的值（以太坊地址的大小）。
> - address payable ：可支付地址，与 `address` 相同，不过有成员函数 `transfer` 和 `send` 。

这种区别背后的思想是 address payable 可以接受以太币的地址，而一个普通的 address 则不能。

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract Payable {
    // 可支付地址可以接收以太币
    address payable public owner;

    // 可支付的构造函数可以接收以太币
    constructor() payable {
        owner = payable(msg.sender);
    }

    //将账户中的value以太币转移到合同中
    function deposit() public payable {}

    //调用此函数时同时调用一些Ether；该函数将抛出一个错误，因为该函数是不可支付的。
    function notPayable() public {}

    // 把合约中的以太币转移到执行账户中
    function withdraw() public {
        // 获取该合同中存储的以太币数量
        uint amount = address(this).balance;

        (bool success, ) = owner.call{value: amount}("");
        require(success, "Failed to send Ether");
    }

    // 将合同中的以太币转移到输入地址中
    function transfer(address payable _to, uint _amount) public {
        // “to”被声明为应付款项
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Failed to send Ether");
    }
}
```

##### 类型转换

允许从 address payable 到 address 的隐式转换，而从 address 到 address payable 的转换是不可以的（ 执行这种转换的唯一方法是使用中间类型，先转换为 uint160 ），如:

```
address payable ap = address(uint160(addr));
```

address 可以显式和整型、整型字面常量、bytes20 及合约类型相互转换。转换时需注意：不允许以 address payable(x) 形式转换。 如果 x 是整型或定长字节数组、字面常量或具有可支付的回退（ payable fallback ）函数的合约类型，则转换形式 address(x) 的结果是 address payable 类型。 如果 x 是没有可支付的回退（ payable fallback ）函数的合约类型，则 address(x) 将是 address类型。 在外部函数签名（定义）中，address 可用来表示 address 和 address payable 类型。

> 大部分情况下你不需要关心 address 与 address payable 之间的区别，并且到处都使用 address。 例如，如果你在使用  取款模式, 你可以（也应该）保存地址为 address 类型, 因为可以在msg.sender 对象上调用 transfer 函数, 因为 msg.sender 是 address payable。

###### address payable 转换为address

`address payable`类型的变量可以显式或隐式地转换为address类型：

```
address payable addr1 = msg.sender;
address addr2 = addr1; // 正确
address addr3 = address(addr1); // 正确
```

###### address转换为address payable

`address`类型的变量只能显式地转换为`address payable`，需要首先转换为整数类型（例如uint160），然后再将该整型值转换为address类型，就可以得到`address payable`：

```
address addr1 = msg.sender;
address payable addr2 = addr1; // 错误，address不能隐式地转换为address payable
address payable addr3 = address(uint160(addr1)); // 正确，先转换为uint160，然后转换为address payable
```

###### address[]或address payable[]的转换

虽然单个address payable变量可以转换为address类型，或者反之，但是不能直接将整个数组
进行转换。例如：

```
function testCast(address payable[] memory _addresses) returns (address[] memory)
{
    return _addresses; // 错误！
}
```

##### 运算符

`<=`，`<`，`==`，`!=`，`>=`和`>`

##### 地址类型成员变量

查看所有的成员，可参考 [地址成员](https://learnblockchain.cn/docs/solidity/units-and-global-variables.html#address-related)。

- `balance` 和 `transfer`

可以使用 `balance` 属性来查询一个地址的余额， 也可以使用 `transfer` 函数向一个可支付地址（payable address）发送 以太币Ether （以 wei 为单位）：

```
address x = 0x123;
address myAddress = this;
if (x.balance < 10 && myAddress.balance >= 10) x.transfer(10);
```

如果当前合约的余额不够多，则 `transfer` 函数会执行失败，或者如果以太转移被接收帐户拒绝， `transfer` 函数同样会失败而进行回退。

> 如果 x 是一个合约地址，它的代码（更具体来说是它的 Fallback 函数，如果有的话）会跟 transfer 函数调用一起执行（这是 EVM 的一个特性，无法阻止）。 如果在执行过程中用光了 gas 或者因为任何原因执行失败，以太币Ether 交易会被打回，当前的合约也会在终止的同时抛出异常。

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract addressTest {
	// 通过它能得到一个地址的余额。balance
    function getBalance(address addr) public view returns (uint){
        return addr.balance;
    }
}
```

this 如果只是想得到当前合约的余额，其实可以这样写

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract addressTest {
    function getBalance() public view returns (uint){
        return address(this).balance;
    }
}
```

- `send`

`send` 是 `transfer` 的低级版本。如果执行失败，当前的合约不会因为异常而终止，但 `send` 会返回 `false`。

> 在使用 send 的时候会有些风险：如果调用栈深度是 1024 会导致发送失败（这总是可以被调用者强制），如果接收者用光了 gas 也会导致发送失败。 所以为了保证 以太币Ether 发送的安全，一定要检查 send 的返回值，使用 transfer 或者更好的办法： 使用接收者自己取回资金的模式。

- `call`， `delegatecall` 和 `staticcall`

为了与不符合 应用二进制接口Application Binary Interface(ABI) 的合约交互，或者要更直接地控制编码，提供了函数 `call`，`delegatecall` 和 `staticcall` 。 它们都带有一个 `bytes memory` 参数和返回执行成功状态（`bool`）和数据（`bytes memory`）。

函数 `abi.encode`，`abi.encodePacked`，`abi.encodeWithSelector` 和 `abi.encodeWithSignature` 可用于编码结构化数据。

```
bytes memory payload = abi.encodeWithSignature("register(string)", "MyName");
(bool success, bytes memory returnData) = address(nameReg).call(payload);
require(success);
```

此外，为了与不符合 应用二进制接口Application Binary Interface(ABI) 的合约交互，于是就有了可以接受任意类型任意数量参数的 `call` 函数。 这些参数会被打包到以 32 字节为单位的连续区域中存放。 其中一个例外是当第一个参数被编码成正好 4 个字节的情况。 在这种情况下，这个参数后边不会填充后续参数编码，以允许使用函数签名。

```
address nameReg = 0x72ba7d8e73fe8eb666ea66babc8116a41bfb10e2;
nameReg.call("register", "MyName");
nameReg.call(bytes4(keccak256("fun(uint256)")), a);
```

> 所有这些函数都是低级函数，应谨慎使用。 具体来说，任何未知的合约都可能是恶意的，我们在调用一个合约的同时就将控制权交给了它，而合约又可以回调合约，所以要准备好在调用返回时改变相应的状态变量（可参考  可重入 )， 与其他合约交互的常规方法是在合约对象上调用函数（x.f()）。

可以使用 `gas` 修改器modifier 调整提供的 gas 数量：

```
address(nameReg).call{gas: 1000000}(abi.encodeWithSignature("register(string)", "MyName"));
```

类似地，也能控制提供的 以太币Ether 的值：

```
address(nameReg).call{value: 1 ether}(abi.encodeWithSignature("register(string)", "MyName"));
```

最后一点，这些 修改器modifier 可以联合使用。每个修改器出现的顺序不重要：

```
address(nameReg).call{gas: 1000000, value: 1 ether}(abi.encodeWithSignature("register(string)", "MyName"));
```

以类似的方式，可以使用函数 `delegatecall` ：区别在于只调用给定地址的代码（函数），其他状态属性如（存储，余额 …）都来自当前合约。 `delegatecall` 的目的是使用另一个合约中的库代码。 用户必须确保两个合约中的存储结构都适合委托调用 （delegatecall）。

从以太坊拜占庭（byzantium）版本开始 提供了 `staticcall` ，它与 `call` 基本相同，但如果被调用的函数以任何方式修改状态变量，都将回退。

所有三个函数 `call` ， `delegatecall` 和 `staticcall` 都是非常低级的函数，应该只把它们当作 *最后一招* 来使用，因为它们破坏了 Solidity 的类型安全性。

所有三种方法都提供 `gas` 选项，而 `value` 选项仅 `call` 支持 。

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Primitives {
    bool public boo = true;

    /*
    Uint代表无符号整数，即非负整数
	不同尺寸可选
        uint8   ranges from 0 to 2 ** 8 - 1
        uint16  ranges from 0 to 2 ** 16 - 1
        ...
        uint256 ranges from 0 to 2 ** 256 - 1
    */
    uint8 public u8 = 1;
    uint public u256 = 456;
    uint public u = 123; // Uint是uint256的别名

    /*
    整数类型允许为负数。
	与uint一样，从int8到int256可以使用不同的范围
    int256 ranges from -2 ** 255 to 2 ** 255 - 1
    int128 ranges from -2 ** 127 to 2 ** 127 - 1
    */
    int8 public i8 = -1;
    int public i256 = 456;
    int public i = -123; // int is same as int256

    // int的最小值和最大值
    int public minInt = type(int).min;
    int public maxInt = type(int).max;

    address public addr = 0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c;

    /*
    在Solidity中，数据类型byte表示一个字节序列。
	solidity提供了两种类型的字节:
        -固定大小的字节数组
        -动态大小的字节数组。
	Solidity中的字节表示一个动态字节数组。
	它是byte[]的简写。
    */
    bytes1 a = 0xb5; //  [10110101]
    bytes1 b = 0x56; //  [01010110]

    // Default values
    // 未赋值的变量有一个默认值
    bool public defaultBoo; // false
    uint public defaultUint; // 0
    int public defaultInt; // 0
    address public defaultAddr; // 0x0000000000000000000000000000000000000000
}
```

> 所有合约都可以转换为 address 类型，因此可以使用 address(this).balance 查询当前合约的余额

#### 字节数组 byte arrays

##### 定长字节数组 Fixed-size byte arrays

`bytes1`， ... ，`bytes32`，允许值以步长`1`递增。`byte`默认表示`byte1`。

###### 运算符

比较：`<=`，`<`，`==`，`!=`，`>=`，`>`，返回值为`bool`类型。

位运算符：`&`，`|`，`^`(异或)，`~`非

支持序号的访问，与大多数语言一样，取值范围[0, n)，其中`n`表示长度。

###### 成员变量

`.length`表示这个字节数组的长度（只读）。

##### 动态大小的字节数组

`bytes`： 动态长度的字节数组，参见[数组(Arrays)](https://solidity.tryblockchain.org/Solidity-Array-数组.html)。非值类型[1](https://solidity.tryblockchain.org/Solidity-Type-ByteArrays-字节数组.html#fn1)。

`string`： 动态长度的UTF-8编码的字符类型，参见[数组(Arrays)](https://solidity.tryblockchain.org/Solidity-Array-数组.html)。非值类型[valueType]。

一个好的使用原则是:

- `bytes`用来存储任意长度的字节数据，`string`用来存储任意长度的`UTF-8`编码的字符串数据。
- 如果长度可以确定，尽量使用定长的如`byte1`到`byte32`中的一个，因为这样更省空间。

#### 字符串 String literal

##### 字符串字面量

字符串字面量是指由单引号，或双引号引起来的字符串。字符串并不像C语言，包含结束符，`foo`这个字符串大小仅为三个字节。

##### 定长字节数组

正如整数一样，字符串的长度类型可以是变长的。特殊之处在于，可以隐式的转换为`byte1`,...`byte32`。下面来看看这个特性：

```text
pragma solidity ^0.4.0;

contract StringConvert{
    function test() returns (bytes3){
      bytes3 a = "123";

      //bytes3 b = "1234";
      //Error: Type literal_string "1234" is not implicitly convertible to expected type bytes3.

      return a;
  }
}
```

上述的字符串字面量，会隐式转换为`bytes3`。但这样不是理解成`bytes3`的字面量方式一个意思。

##### 转义字符

字符串字面量支持转义字符，比如`\n`，`\xNN`，`\uNNNN`。其中`\xNN`表式16进制值，最终录入合适的字节。而`\uNNNN`表示`Unicode`码点值，最终会转换为`UTF8`的序列。

#### 枚举

枚举类型是在Solidity中的一种用户自定义类型。他可以显示的转换与整数进行转换，但不能进行隐式转换。显示的转换会在运行时检查数值范围，如果不匹配，将会引起异常。枚举类型应至少有一名成员。我们来看看下面的例子吧。

使用 `type(NameOfEnum).min` 和 `type(NameOfEnum).max` 你可以得到给定枚举的最小值和最大值。

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.8;

contract test {
    enum ActionChoices { GoLeft, GoRight, GoStraight, SitStill }
    ActionChoices choice;
    ActionChoices constant defaultChoice = ActionChoices.GoStraight;

    function setGoStraight() public {
        choice = ActionChoices.GoStraight;
    }

    // 由于枚举类型不属于 |ABI| 的一部分，因此对于所有来自 Solidity 外部的调用，
    // "getChoice" 的签名会自动被改成 "getChoice() returns (uint8)"。

    function getChoice() public view returns (ActionChoices) {
        return choice;
    }

    function getDefaultChoice() public pure returns (uint) {
        return uint(defaultChoice);
    }

    function getLargestValue() public pure returns (ActionChoices) {
        return type(ActionChoices).max;
    }

    function getSmallestValue() public pure returns (ActionChoices) {
        return type(ActionChoices).min;
    }
}
```

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Enum {
    // Enum representing shipping status
    enum Status {
        Pending,
        Shipped,
        Accepted,
        Rejected,
        Canceled
    }
    
    // 默认值为 类型的定义，在本例中为"Pending"
    Status public status;

    // Returns uint
    // Pending  - 0
    // Shipped  - 1
    // Accepted - 2
    // Rejected - 3
    // Canceled - 4
    function get() public view returns (Status) {
        return status;
    }

    // 通过将uint传入input来更新状态
    function set(Status _status) public {
        status = _status;
    }

    // 您可以像这样更新到特定的枚举
    function cancel() public {
        status = Status.Accepted;
    }

    // delete resets the enum to its first value, 0
    function reset() public {
        delete status;
    }
}
```
