### 引用类型 Reference Type

复杂类型。不同于之前值类型，复杂类型占的空间更大，超过256字节，因为拷贝它们占用更多的空间。由此我们需要考虑将它们存储在什么位置`内存（memory，数据不是永久存在的）`或`存储(storage，值类型中的状态变量)`

#### 数据位置 Data location

复杂类型，如`数组(arrays)`和`数据结构(struct)`在Solidity中有一个额外的属性，数据的存储位置。可选为`memory`和`storage`。

`memory`存储位置同我们普通程序的内存一致。即分配，即使用，越过作用域即不可被访问，等待被回收。而在区块链上，由于底层实现了图灵完备，故而会有非常多的状态需要永久记录下来。比如，参与众筹的所有参与者。那么我们就要使用`storage`这种类型了，一旦使用这个类型，数据将永远存在。

基于程序的上下文，大多数时候这样的选择是默认的，我们可以通过指定关键字`storage`和`memory`修改它。

默认的函数参数，包括返回的参数，他们是`memory`。默认的局部变量是`storage`的。而默认的状态变量（合约声明的公有变量）是`storage`。

另外还有第三个存储位置`calldata`。它存储的是函数参数，是只读的，不会永久存储的一个数据位置。`外部函数`的参数（不包括返回参数）被强制指定为`calldata`。效果与`memory`差不多。

1. `storage`：合约里的状态变量默认都是`storage`，存储在链上。
2. `memory`：函数里的参数和临时变量一般用`memory`，存储在内存中，不上链。
3. `calldata`：和`memory`类似，存储在内存中，不上链。与`memory`的不同点在于`calldata`变量不能修改（`immutable`），一般用于函数的参数

数据位置指定非常重要，因为不同数据位置变量赋值产生的结果也不同。在`memory`和`storage`之间，以及它们和`状态变量`（即便从另一个状态变量）中相互赋值，总是会创建一个完全不相关的拷贝。

将一个`storage`的状态变量，赋值给一个`storage`的局部变量，是通过引用传递。所以对于局部变量的修改，同时修改关联的状态变量。但另一方面，将一个`memory`的引用类型赋值给另一个`memory`的引用，不会创建另一个拷贝。

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;

contract Tiny {
    uint[] x; // x 的数据存储位置是 storage，　位置可以忽略

    // memoryArray 的数据存储位置是 memory
    function f(uint[] memory memoryArray) public {
        x = memoryArray; // 将整个数组拷贝到 storage 中，可行
        uint[] storage y = x;  // 分配一个指针（其中 y 的数据存储位置是 storage），可行
        y[7]; // 返回第 8 个元素，可行
        y.pop(); // 通过 y 修改 x，可行
        delete x; // 清除数组，同时修改 y，可行

        // 下面的就不可行了；需要在 storage 中创建新的未命名的临时数组，
        // 但 storage 是“静态”分配的：
        // y = memoryArray;
        // 下面这一行也不可行，因为这会“重置”指针，
        // 但并没有可以让它指向的合适的存储位置。
        // delete y;

        g(x); // 调用 g 函数，同时移交对 x 的引用
        h(x); // 调用 h 函数，同时在 memory 中创建一个独立的临时拷贝
    }

    function g(uint[] storage ) internal pure {}
    function h(uint[] memory) public pure {}
}
```

##### 强制的数据位置(Forced data location)

- `外部函数(External function)`的参数(不包括返回参数)强制为：`calldata`
- `状态变量(State variables)`强制为: `storage`

##### 默认数据位置（Default data location）

- 函数参数（括返回参数：`memory`
- 所有其它的局部变量：`storage`