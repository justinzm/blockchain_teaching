### 函数(Funtion)

可以在合约内部和外部定义函数。

合约之外的函数（也称为“自由函数”）始终具有隐式的 `internal` [可见性](https://learnblockchain.cn/docs/solidity/contracts.html#visibility-and-getters)。 它们的代码包含在所有调用它们合约中，类似于内部库函数。

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.1 <0.9.0;

function sum(uint[] memory arr) pure returns (uint s) {
    for (uint i = 0; i < arr.length; i++)
        s += arr[i];
}

contract ArrayExample {
    bool found;
    function f(uint[] memory arr) public {
        // This calls the free function internally.
        // The compiler will add its code to the contract.
        uint s = sum(arr);
        require(s >= 10);
        found = true;
    }
}
```

#### 函数参数与返回值

与 Javascript 一样，函数可能需要参数作为输入; 而与 Javascript 和 C 不同的是，它们可能返回任意数量的参数作为输出。

##### 函数参数（输入参数）

函数参数的声明方式与变量相同。不过未使用的参数可以省略参数名。

例如，如果我们希望合约接受有两个整数形参的函数的外部调用，可以像下面这样写：

```
pragma solidity >=0.4.16 <0.9.0;

contract Simple {
    uint sum;
    function taker(uint a, uint b) public {
        sum = a + b;
    }
}
```

函数参数可以当作为本地变量，也可用在等号左边被赋值。

##### 返回变量

函数返回变量的声明方式在关键词 `returns` 之后，与参数的声明方式相同。

例如，如果我们需要返回两个结果：两个给定整数的和与积，我们应该写作：

```
pragma solidity >=0.4.16 <0.9.0;

contract Simple {
    function arithmetic(uint a, uint b)
        public
        pure
        returns (uint sum, uint product)
    {
        sum = a + b;
        product = a * b;
    }
}
```

返回变量名可以被省略。 返回变量可以当作为函数中的本地变量，没有显式设置的话，会使用 :ref:` 默认值 <default-value>` 返回变量可以显式给它附一个值(像上面)，也可以使用 `return` 语句指定，使用 `return` 语句可以一个或多个值，参阅 [multiple ones](https://learnblockchain.cn/docs/solidity/contracts.html#multi-return) 。

```
pragma solidity >=0.4.16 <0.9.0;

contract Simple {
    function arithmetic(uint a, uint b)
        public
        pure
        returns (uint sum, uint product)
    {
        return (a + b, a * b);
    }
}
```

这个形式等同于赋值给返回参数，然后用 `return;` 退出。

如果使用 `return` 提前退出有返回值的函数， 必须在用 return 时提供返回值。

##### 返回多个值

当函数需要使用多个值，可以用语句 `return (v0, v1, ..., vn)` 。 参数的数量需要和声明时候一致。

#### 状态可变性

##### View 函数

可以将函数声明为 `view` 类型，这种情况下要保证不修改状态。

下面的语句被认为是修改状态：

1. 修改状态变量。
2. 产生事件。
3. 创建其它合约。
4. 使用 `selfdestruct`。
5. 通过调用发送以太币。
6. 调用任何没有标记为 `view` 或者 `pure` 的函数。
7. 使用低级调用。
8. 使用包含特定操作码的内联汇编。

```
pragma solidity ^0.4.16;

contract C {
    function f(uint a, uint b) public view returns (uint) {
        return a * (b + 42) + now;
    }
}
```

##### Pure 函数

函数可以声明为 `pure` ，在这种情况下，承诺不读取或修改状态。

除了上面解释的状态修改语句列表之外，以下被认为是从状态中读取：

1. 读取状态变量。
2. 访问 `this.balance` 或者 `<address>.balance`。
3. 访问 `block`，`tx`， `msg` 中任意成员 （除 `msg.sig` 和 `msg.data` 之外）。
4. 调用任何未标记为 `pure` 的函数。
5. 使用包含某些操作码的内联汇编。

```
pragma solidity ^0.4.16;

contract C {
    function f(uint a, uint b) public pure returns (uint) {
        return a * (b + 42);
    }
}
```

#### 特别的函数

##### receive 接收以太函数

一个合约最多有一个 `receive` 函数, 声明函数为： `receive() external payable { ... }`

不需要 `function` 关键字，也没有参数和返回值并且必须是　`external`　可见性和　`payable` 修饰． 它可以是 `virtual` 的，可以被重载也可以有 修改器modifier 。

在对合约没有任何附加数据调用（通常是对合约转账）是会执行 `receive` 函数．　例如　通过 `.send()` or `.transfer()` 如果 `receive` 函数不存在，　但是有payable　的 [fallback 回退函数](https://learnblockchain.cn/docs/solidity/contracts.html#fallback-function) 那么在进行纯以太转账时，fallback 函数会调用．

如果两个函数都没有，这个合约就没法通过常规的转账交易接收以太（会抛出异常）．

更糟的是，`receive` 函数可能只有 2300 gas 可以使用（如，当使用 `send` 或 `transfer` 时）， 除了基础的日志输出之外，进行其他操作的余地很小。下面的操作消耗会操作 2300 gas :

- 写入存储
- 创建合约
- 调用消耗大量 gas 的外部函数
- 发送以太币

下面是一个例子：

```
pragma solidity ^0.6.0;

// 这个合约会保留所有发送给它的以太币，没有办法取回。
contract Sink {
    event Received(address, uint);
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}
```

##### Fallback 回退函数

合约可以最多有一个回退函数。函数声明为： `fallback () external [payable]` 或 `fallback (bytes calldata input) external [payable] returns (bytes memory output)`

没有　`function`　关键字。　必须是　`external`　可见性，它可以是 `virtual` 的，可以被重载也可以有 修改器modifier 。

如果在一个对合约调用中，没有其他函数与给定的函数标识符匹配fallback会被调用． 或者在没有 [receive 函数](https://learnblockchain.cn/docs/solidity/contracts.html#receive-ether-function)　时，而没有提供附加数据对合约调用，那么fallback 函数会被执行。

fallback　函数始终会接收数据，但为了同时接收以太时，必须标记为　`payable` 。

如果使用了带参数的版本， `input` 将包含发送到合约的完整数据（等于 `msg.data` ），并且通过 `output` 返回数据。 返回数据不是 ABI 编码过的数据，相反，它返回不经过修改的数据。

更糟的是，如果回退函数在接收以太时调用，可能只有 2300 gas 可以使用，参考　[receive接收函数](https://learnblockchain.cn/docs/solidity/contracts.html#receive-ether-function)

与任何其他函数一样，只要有足够的 gas 传递给它，回退函数就可以执行复杂的操作。

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.2 <0.9.0;

contract Test {
    // 发送到这个合约的所有消息都会调用此函数（因为该合约没有其它函数）。
    // 向这个合约发送以太币会导致异常，因为 fallback 函数没有 `payable` 修饰符
    fallback() external { x = 1; }
    uint x;
}

// 这个合约会保留所有发送给它的以太币，没有办法返还。
contract TestPayable {
    uint x;
    uint y;

    // 除了纯转账外，所有的调用都会调用这个函数．
    // (因为除了 receive 函数外，没有其他的函数).
    // 任何对合约非空calldata 调用会执行回退函数(即使是调用函数附加以太).
    fallback() external payable { x = 1; y = msg.value; }

    // 纯转账调用这个函数，例如对每个空empty calldata的调用
    receive() external payable { x = 2; y = msg.value; }
}

contract Caller {
    function callTest(Test test) public returns (bool) {
        (bool success,) = address(test).call(abi.encodeWithSignature("nonExistingFunction()"));
        require(success);
        //  test.x 结果变成 == 1。

        // address(test) 不允许直接调用 ``send`` ,  因为 ``test`` 没有 payable 回退函数
        //  转化为 ``address payable`` 类型 , 然后才可以调用 ``send``
        address payable testPayable = payable(address(test));


        // 以下将不会编译，但如果有人向该合约发送以太币，交易将失败并拒绝以太币。
        // test.send(2 ether）;
    }

    function callTestPayable(TestPayable test) public returns (bool) {
        (bool success,) = address(test).call(abi.encodeWithSignature("nonExistingFunction()"));
        require(success);
        // 结果 test.x 为 1  test.y 为 0.
        (success,) = address(test).call{value: 1}(abi.encodeWithSignature("nonExistingFunction()"));
        require(success);
        // 结果test.x 为1 而 test.y 为 1.

        // 发送以太币, TestPayable 的 receive　函数被调用．

        // 因为函数有存储写入, 会比简单的使用 ``send`` or ``transfer``消耗更多的 gas。
        // 因此使用底层的call调用
        (success,) = address(test).call{value: 2 ether}("");
        require(success);

        // 结果 test.x 为 2 而 test.y 为 2 ether.

        return true;
    }
}
```

#### 