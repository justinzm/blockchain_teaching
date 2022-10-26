### 函数类型 function Types

函数类型即是函数这种特殊的类型。

- 可以将一个函数赋值给一个变量，一个函数类型的变量。
- 还可以将一个函数作为参数进行传递。
- 也可以在函数调用中返回一个函数。

函数类型有两类;可分为`internal`和`external`函数。

#### 内部函数(internal)

因为不能在当前合约的上下文环境以外的地方执行，内部函数只能在当前合约内被使用。如在当前的代码块内，包括内部库函数，和继承的函数中。

#### 外部函数（External）

外部函数由地址和函数方法签名两部分组成。可作为`外部函数调用`的参数，或者由`外部函数调用`返回。

#### 函数的定义

完整的函数的定义如下:

```text
function <function name>(<parameter types>) {internal|external|public|private} [pure|view|payable] [returns (<return types>)]
```

* `function`：声明函数时的固定用法，想写函数，就要以function关键字开头；
* `<function name>`：函数名；
* `(<parameter types>)`：圆括号里写函数的参数，也就是要输入到函数的变量类型和名字；
* `{internal|external|public|private}`：函数可见性说明符，一共4种。没标明函数类型的，默认`internal`；
  * `public`: 内部外部均可见。(也可用于修饰状态变量，public变量会自动生成 `getter`函数，用于查询数值)；
  * `private`: 只能从本合约内部访问，继承的合约也不能用（也可用于修饰状态变量）；
  * `external`: 只能从合约外部访问（但是可以用`this.f()`来调用，`f`是函数名）；
  * `internal`: 只能从合约内部访问，继承的合约可以用（也可用于修饰状态变量）；
* `[pure|view|payable]`：决定函数权限/功能的关键字。`payable`（可支付的）很好理解，带着它的函数，运行的时候可以给合约转入`ETH`。
* `[returns ()]`：函数返回的变量类型和名称

与参数类型相反，返回类型不能为空 —— 如果函数类型不需要返回，则需要删除整个 `returns (<return types>)` 部分。

#### `Pure`和`View`

`solidity`加入这两个关键字，是因为`gas fee`。合约的状态变量存储在链上，`gas fee`很贵，如果不改变链上状态，就不用付`gas`。包含`pure`跟`view`关键字的函数是不改写链上状态的，因此用户直接调用他们是不需要付gas的（合约中非`pure`/`view`函数调用它们则会改写链上状态，需要付gas）。

在以太坊中，以下语句被视为修改链上状态：

1. 写入状态变量。
2. 释放事件。
3. 创建其他合同。
4. 使用`self destruct`.
5. 通过调用发送以太币。
6. 调用任何未标记`view`或`pure`的函数。
7. 使用低级调用（low-level calls）。
8. 使用包含某些操作码的内联汇编。

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract ViewAndPure {
    uint public x = 1;

    // Promise not to modify the state.
    function addToX(uint y) public view returns (uint) {
        return x + y;
    }

    // Promise not to modify or read from the state.
    function add(uint i, uint j) public pure returns (uint) {
        return i + j;
    }
}
```

#### 类型转换

函数类型 `A` 可以隐式转换为函数类型 `B` 当且仅当: 它们的参数类型相同，返回类型相同，它们的内部/外部属性是相同的，并且 `A` 的状态可变性比 `B` 的状态可变性更具限制性，比如：

- `pure` 函数可以转换为 `view` 和 `non-payable` 函数
- `view` 函数可以转换为 `non-payable` 函数
- `payable` 函数可以转换为 `non-payable` 函数

其他的转换则不可以。

关于 `payable` 和 `non-payable` 的规则可能有点令人困惑，但实质上，如果一个函数是 `payable` ，这意味着它可以接受以太币的支付，因此它也是 `non-payable` 。 另一方面，`non-payable` 函数将拒绝发送给它的 以太币Ether ， 所以 `non-payable` 函数不能转换为 `payable` 函数。

如果当函数类型的变量还没有初始化时就调用它的话会引发一个 [Panic 异常](https://learnblockchain.cn/docs/solidity/control-structures.html#assert-and-require)。 如果在一个函数被 `delete` 之后调用它也会发生相同的情况。

如果外部函数类型在 Solidity 的上下文环境以外的地方使用，它们会被视为 `function` 类型。 该类型将函数地址紧跟其函数标识一起编码为一个 `bytes24` 类型。。

>  请注意，当前合约的 public 函数既可以被当作内部函数也可以被当作外部函数使用。 如果想将一个函数当作内部函数使用，就用 `f` 调用，如果想将其当作外部函数，使用 `this.f` 。

一个内部函数可以被分配给一个内部函数类型的变量，无论定义在哪里，包括合约和库的私有、内部和public函数，以及自由函数。 另一方面，外部函数类型只与public和外部合约函数兼容。库是不可以的，因为库使用 `delegatecall`，并且 [他们的函数选择器有不同的 ABI 转换](https://learnblockchain.cn/docs/solidity/contracts.html#library-selectors) 。 接口中声明的函数没有定义，所以指向它们也没有意义。

使用内部函数类型的例子：

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16  <0.9.0;

library ArrayUtils {
  // 内部函数可以在内部库函数中使用，
  // 因为它们会成为同一代码上下文的一部分
  function map(uint[] memory self, function (uint) pure returns (uint) f)
    internal
    pure
    returns (uint[] memory r)
  {
    r = new uint[](self.length);
    for (uint i = 0; i < self.length; i++) {
      r[i] = f(self[i]);
    }
  }
  function reduce(
    uint[] memory self,
    function (uint, uint) pure returns (uint) f
  )
    internal
    pure
    returns (uint r)
  {
    r = self[0];
    for (uint i = 1; i < self.length; i++) {
      r = f(r, self[i]);
    }
  }
  function range(uint length) internal pure returns (uint[] memory r) {
    r = new uint[](length);
    for (uint i = 0; i < r.length; i++) {
      r[i] = i;
    }
  }
}

contract Pyramid {
  using ArrayUtils for *;
  function pyramid(uint l) public pure returns (uint) {
    return ArrayUtils.range(l).map(square).reduce(sum);
  }
  function square(uint x) internal pure returns (uint) {
    return x * x;
  }
  function sum(uint x, uint y) internal pure returns (uint) {
    return x + y;
  }
}
```

使用外部函数类型的例子：

```
pragma solidity >=0.4.22  <0.9.0;

contract Oracle {
  struct Request {
    bytes data;
    function(uint) external callback;
  }
  Request[] private requests;
  event NewRequest(uint);
  function query(bytes memory data, function(uint) external callback) public {
    requests.push(Request(data, callback));
    emit NewRequest(requests.length - 1);
  }
  function reply(uint requestID, uint response) public {
    // 这里检查回复来自可信来源
    requests[requestID].callback(response);
  }
}

contract OracleUser {
  Oracle constant private ORACLE_CONST = Oracle(address(0x00000000219ab540356cBB839Cbe05303d7705Fa)); // known contract
  uint private exchangeRate;
  function buySomething() public {
    ORACLE_CONST.query("USD", this.oracleResponse);
  }
  function oracleResponse(uint response) public {
    require(
        msg.sender == address(ORACLE_CONST),
        "Only oracle can call this."
    );
    exchangeRate = response;
  }
}
```

