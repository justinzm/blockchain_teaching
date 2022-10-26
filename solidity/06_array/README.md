### 数组

数组可以在声明时指定长度，也可以动态调整大小（长度）。

一个元素类型为 `T`，固定长度为 `k` 的数组可以声明为 `T[k]`，而动态数组声明为 `T[]`。 举个例子，一个长度为 5，元素类型为 `uint` 的动态数组的数组（二维数组），应声明为 `uint[][5]` （注意这里跟其它语言在Solidity中， `X[3]` 总是一个包含三个 `X` 类型元素的数组，即使 `X` 本身就是一个数组，这和其他语言也有所不同，比如 C 语言。

在Solidity中， `X[3]` 总是一个包含三个 `X` 类型元素的数组，即使 `X` 本身就是一个数组，这和其他语言也有所不同，比如 C 语言。

数组下标是从 0 开始的，且访问数组时的下标顺序与声明时相反。

如：如果有一个变量为 `uint[][5] memory x`， 要访问第三个动态数组的第7个元素，使用 x[2] [6]，要访问第三个动态数组使用 `x[2]`。 同样，如果有一个 `T` 类型的数组 `T[5] a` ， T 也可以是一个数组，那么 `a[2]` 总会是 `T` 类型。

数组元素可以是任何类型，包括映射或结构体。对类型的限制是映射只能存储在 存储storage 中，并且公开访问函数的参数需要是 ABI 类型。

状态变量标记 `public` 的数组，Solidity创建一个 getter函数 。 小标数字索引就是 getter函数 的参数。

访问超出数组长度的元素会导致异常（assert 类型异常 ）。 可以使用 `.push()` 方法在末尾追加一个新元素，其中 `.push()` 追加一个零初始化的元素并返回对它的引用。

#### `bytes` 和 `string` 也是数组

`bytes` 和 `string` 类型的变量是特殊的数组。 `bytes` 类似于 `bytes1[]`，但它在 调用数据calldata 和 内存memory 中会被“紧打包”（译者注：将元素连续地存在一起，不会按每 32 字节一单元的方式来存放）。 `string` 与 `bytes` 相同，但不允许用长度或索引来访问。

Solidity没有字符串操作函数，但是可以使用第三方字符串库，我们可以比较两个字符串通过计算他们的 keccak256-hash ，可使用 `keccak256(abi.encodePacked(s1)) == keccak256(abi.encodePacked(s2))` 和使用 `string.concat(s1, s2)` 来拼接字符串。

我们更多时候应该使用 `bytes` 而不是 `bytes1[]` ，因为Gas 费用更低, 在内存memory 中使用 `bytes1[]` 时，会在元素之间添加31个填充字节。 而在存储storage 中，由于紧密包装，这没有填充字节， 参考 [bytes and string](https://learnblockchain.cn/docs/solidity/internals/layout_in_storage.html#bytes-and-string) 。 作为一个基本规则，对任意长度的原始字节数据使用 `bytes`，对任意长度字符串（UTF-8）数据使用 `string` 。

如果使用一个长度限制的字节数组，应该使用一个 `bytes1` 到 `bytes32` 的具体类型，因为它们便宜得多。

> 如果想要访问以字节表示的字符串 `s`，请使用 `bytes(s).length` / `bytes(s)[7] = 'x';`。 注意这时你访问的是 UTF-8 形式的低级 bytes 类型，而不是单个的字符。

#### 函数 `bytes.concat` 和 `string.concat`

可以使用 `string.concat` 连接任意数量的 `string` 字符串。 该函数返回一个 `string memory` ，包含所有参数的内容，无填充方式拼接在一起。 如果你想使用不能隐式转换为 `string` 的其他类型作为参数，你需要先把它们转换为 `string`。

同样， `bytes.concat` 函数可以连接任意数量的 `bytes` 或 `bytes1 ... bytes32` 值。 该函数返回一个 `bytes memory` ，包含所有参数的内容，无填充方式拼接在一起。 如果你想使用字符串参数或其他不能隐式转换为 `bytes` 的类型，你需要先将它们转换为 `bytes``或 ``bytes1`/…/ `bytes32`。

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

contract C {
    string s = "Storage";
    function f(bytes calldata bc, string memory sm, bytes16 b) public view {
        string memory concatString = string.concat(s, string(bc), "Literal", sm);
        assert((bytes(s).length + bc.length + 7 + bytes(sm).length) == bytes(concatString).length);

        bytes memory concatBytes = bytes.concat(bytes(s), bc, bc[:2], "Literal", bytes(sm), b);
        assert((bytes(s).length + bc.length + 2 + 7 + bytes(sm).length + b.length) == concatBytes.length);
    }
}
```

如果你调用不使用参数调用 `string.concat` 或 `bytes.concat` 将返回空数组。

#### 创建内存数组

可使用 `new` 关键字在 内存memory 中基于运行时创建动态长度数组。 与存储storage 数组相反的是，你不能通过修改成员变量 `.push` 改变 内存memory 数组的大小。

必须提前计算所需的大小或者创建一个新的内存数组并复制每个元素。

在Solidity中的所有变量，新分配的数组元素总是以 [默认值](https://learnblockchain.cn/docs/solidity/control-structures.html#default-value) 初始化。

```
pragma solidity >=0.4.16 <0.9.0;

contract TX {
    function f(uint len) public pure {
        uint[] memory a = new uint[](7);
        bytes memory b = new bytes(len);

        assert(a.length == 7);
        assert(b.length == len);

        a[6] = 8;
    }
}
```

```
pragma solidity ^0.4.0;

contract C {
    function f() {
        //创建一个memory的数组
        uint[] memory a = new uint[](7);
        
        //不能修改长度
        //Error: Expression has to be an lvalue.
        //a.length = 100;
    }
    
    //storage
    uint[] b;
    
    function g(){
        b = new uint[](7);
        //可以修改storage的数组
        b.length = 10;
        b[9] = 100;
    }
}
```

#### 数组常量

数组常量（字面量）是在方括号中（ `[...]` ） 包含一个或多个逗号分隔的表达式。例如 `[1, a, f(3)]` 。

数组常量的类型通过以下的方式确定:

它总是一个静态大小的内存数组，其长度为表达式的数量。

数组的基本类型是列表上的第一个表达式的类型，以便所有其他表达式可以隐式地转换为它。如果不可以转换，将出现类型错误。

所有元素都都可以转换为基本类型也是不够的。其中一个元素必须是这种类型的。

在下面的例子中， `[1, 2, 3]` 的类型是 `uint8[3] memory`。 因为每个常量的类型都是 `uint8` ，如果你希望结果是 `uint[3] memory` 类型，你需要将第一个元素转换为 `uint` 。

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract LBC {
    function f() public pure {
        g([uint(1), 2, 3]);
    }
    function g(uint[3] memory) public pure {
        // ...
    }
}
```

数组常量 `[1, -1]` 是无效的，因为第一个表达式类型是 `uint8` 而第二个类似是 `int8` 他们不可以隐式的相互转换。 为了确保可以运行，你是可以使用例如： `[int8(1), -1]` 。

由于不同类型的固定大小的内存数组不能相互转换(尽管基础类型可以)，如果你想使用二维数组常量，你必须显式地指定一个基础类型:

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract C {
    function f() public pure returns (uint24[2][4] memory) {
        uint24[2][4] memory x = [[uint24(0x1), 1], [0xffffff, 2], [uint24(0xff), 3], [uint24(0xffff), 4]];
        // 下面代码无法工作，因为没有匹配内部类型
        // uint[2][4] memory x = [[0x1, 1], [0xffffff, 2], [0xff, 3], [0xffff, 4]];
        return x;
    }
}
```

目前需要注意的是，定长的 内存memory 数组并不能赋值给变长的 内存memory 数组，下面的例子是无法运行的：

```
pragma solidity  >=0.4.0 <0.9.0;

// 这段代码并不能编译。
contract LBC {
    function f() public {
        // 这一行引发了一个类型错误，因为 unint[3] memory
        // 不能转换成 uint[] memory。
        uint[] x = [uint(1), 3, 4];
    }
}
```

计划在未来移除这样的限制，但目前数组在 ABI 中传递的问题造成了一些麻烦。

如果要初始化动态长度的数组，则必须显示给各个元素赋值:

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;

contract C {
    function f() public pure {
        uint[] memory x = new uint[](3);
        x[0] = 1;
        x[1] = 3;
        x[2] = 4;
    }
}
```

#### 数组成员

**length**:

数组有 `length` 成员变量表示当前数组的长度。 一经创建，内存memory 数组的大小就是固定的（但却是动态的，也就是说，它可以根据运行时的参数创建）。

**push()**:

动态的 存储storage 数组以及 `bytes` 类型（ `string` 类型不可以）都有一个 `push()` 的成员函数，它用来添加新的零初始化元素到数组末尾，并返回元素引用． 因此可以这样：　 `x.push().t = 2` 或 `x.push() = b`.

**push(x)**:

动态的 存储storage 数组以及 `bytes` 类型（ `string` 类型不可以）都有一个 `push(ｘ)` 的成员函数，用来在数组末尾添加一个给定的元素，这个函数没有返回值．

**pop()**:

变长的 存储storage 数组以及 `bytes` 类型（ `string` 类型不可以）都有一个 `pop()` 的成员函数， 它用来从数组末尾删除元素。 同样的会在移除的元素上隐含调用 delete。

> 通过 `push()`　增加 存储storage 数组的长度具有固定的 gas 消耗，因为 存储storage 总是被零初始化，而通过　`pop()`　减少长度则依赖移除与元素的大小（size）．　如果元素是数组,则成本是很高的,因为它包括已删除的元素的清理，类似于在这些元素上调用 [delete](https://learnblockchain.cn/docs/solidity/types.html#delete) 。

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Array {
    // Several ways to initialize an array
    uint[] public arr;
    uint[] public arr2 = [1, 2, 3];
    // 固定大小的数组，所有元素初始化为0
    uint[10] public myFixedSizeArr;

    function get(uint i) public view returns (uint) {
        return arr[i];
    }

    // Solidity可以返回整个数组。
    // 但是这个函数应该避免
    // 数组的长度可以无限增长。
    function getArr() public view returns (uint[] memory) {
        return arr;
    }

    function push(uint i) public {
        // 添加到数组
        // 这将使数组长度增加1。
        arr.push(i);
    }

    function pop() public {
        // 从数组中删除最后一个元素
        // 这将使数组长度减少1
        arr.pop();
    }

    function getLength() public view returns (uint) {
        return arr.length;
    }

    function remove(uint index) public {
        // Delete不改变数组长度。
        // 将index的值重置为默认值，
        // 在本例中为0
        delete arr[index];
    }

    function examples() external {
        // 在内存中创建数组，只能创建固定大小的数组
        uint[] memory a = new uint[](5);
    }
}
```

通过从右向左移动元素来删除数组元素

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract ArrayRemoveByShifting {
    // [1, 2, 3] -- remove(1) --> [1, 3, 3] --> [1, 3]
    // [1, 2, 3, 4, 5, 6] -- remove(2) --> [1, 2, 4, 5, 6, 6] --> [1, 2, 4, 5, 6]
    // [1, 2, 3, 4, 5, 6] -- remove(0) --> [2, 3, 4, 5, 6, 6] --> [2, 3, 4, 5, 6]
    // [1] -- remove(0) --> [1] --> []

    uint[] public arr;

    function remove(uint _index) public {
        require(_index < arr.length, "index out of bound");

        for (uint i = _index; i < arr.length - 1; i++) {
            arr[i] = arr[i + 1];
        }
        arr.pop();
    }

    function test() external {
        arr = [1, 2, 3, 4, 5];
        remove(2);
        // [1, 2, 4, 5]
        assert(arr[0] == 1);
        assert(arr[1] == 2);
        assert(arr[2] == 4);
        assert(arr[3] == 5);
        assert(arr.length == 4);

        arr = [1];
        remove(0);
        // []
        assert(arr.length == 0);
    }
}
```

通过将最后一个元素复制到要删除的位置来删除数组元素

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract ArrayReplaceFromEnd {
    uint[] public arr;

    // 删除一个元素会在数组中产生一个空白。
    // 保持数组紧凑的一个技巧是
    // 移动最后一个元素到要删除的位置。
    function remove(uint index) public {
        // 将最后一个元素移到要删除的位置
        arr[index] = arr[arr.length - 1];
        // Remove the last element
        arr.pop();
    }

    function test() public {
        arr = [1, 2, 3, 4];

        remove(1);
        // [1, 4, 3]
        assert(arr.length == 3);
        assert(arr[0] == 1);
        assert(arr[1] == 4);
        assert(arr[2] == 3);

        remove(2);
        // [1, 4]
        assert(arr.length == 2);
        assert(arr[0] == 1);
        assert(arr[1] == 4);
    }
}
```
