### 可见性和 getter 函数

#### 状态变量可见性

状态变量有 3 种可见性：

- `public`

  对于 public 状态变量会自动生成一个 getter 函数（见下面）。 以便其他的合约读取他们的值。 当在用一个合约里使用是，外部方式访问 (如: `this.x`) 会调用getter 函数，而内部方式访问 (如: `x`) 会直接从存储中获取值。 Setter函数则不会被生成，所以其他合约不能直接修改其值。

- `internal`

  内部可见性状态变量只能在它们所定义的合约和派生合同中访问。 它们不能被外部访问。 这是状态变量的默认可见性。

- `private`

  私有状态变量就像内部变量一样，但它们在派生合约中是不可见的。

#### 函数可见性

由于 Solidity 有两种函数调用：外部调用则会产生一个 EVM 调用，而内部调用不会， 更进一步， 函数可以确定器被内部及派生合约的可访问性，这里有 4 种可见性：

##### external （外部的）：可在外部调用，在内部调用，必须使用this关键词

- 外部函数是合约接口的一部分，仅外部访问；

- 所以我们可以从其他合约或通过交易来发起调用；

- 外部函数在接收大的数组数据时更加有效


##### public （公有的）：可在合约内部和外部访问

- public修饰的函数即允许以内部的internal的方式调用，也允许以外部的external的方式调用；

- public修饰的函数，任何用户或者合约都能调用的访问；

- public的函数由于被外部合约访问，是合约对外接口的一部分


##### internal （内部的）：无法在合约外部调用，可以在子类中调用

仅当前合约及所继承的合约，只允许以internal的方式调用；

* virtual 父类 表示允许被重写
* override 子类 表示我重写了父类的方法

##### private （私有的）：只可在合约内部访问

- private仅当前合约内；

- private修饰函数，只能在其所在的合约中调用和访问，即使是其子合约也没有权限访问；

- 即使声明为private，仍能被所有人查看到里面的数据。访问权限只是阻止了其它合约访问函数的修改数据



可见性标识符的定义位置，对于状态变量来说是在类型后面，对于函数是在参数列表和返回关键字中间。

```
pragma solidity  >=0.4.16 <0.9.0;

contract C {
    function f(uint a) private pure returns (uint b) { return a + 1; }
    function setData(uint a) internal { data = a; }
    uint public data;
}
```

在下面的例子中，`D` 可以调用 `c.getData（）` 来获取状态存储中 `data` 的值，但不能调用 `f` 。 合约 `E` 继承自 `C` ，因此可以调用 `compute`。

```
pragma solidity >=0.4.16 <0.9.0;

contract C {
    uint private data;

    function f(uint a) private returns(uint b) { return a + 1; }
    function setData(uint a) public { data = a; }
    function getData() public returns(uint) { return data; }
    function compute(uint a, uint b) internal returns (uint) { return a+b; }
}

// 下面代码编译错误
contract D {
    function readData() public {
        C c = new C();
        uint local = c.f(7); // 错误：成员 `f` 不可见
        c.setData(3);
        local = c.getData();
        local = c.compute(3, 5); // 错误：成员 `compute` 不可见
    }
}

contract E is C {
    function g() public {
        C c = new C();
        uint val = compute(3, 5); // 访问内部成员（从继承合约访问父合约成员）
    }
}
```

#### Getter函数

编译器自动为所有 **public** 状态变量创建 getter 函数。对于下面给出的合约，编译器会生成一个名为 `data` 的函数， 该函数没有参数，返回值是一个 `uint` 类型，即状态变量 `data` 的值。 状态变量的初始化可以在声明时完成。

```
pragma solidity  >=0.4.16 <0.9.0;

contract C {
    uint public data = 42;
}

contract Caller {
    C c = new C();
    function f() public {
        uint local = c.data();
    }
}
```

getter 函数具有外部（external）可见性。如果在内部访问 getter（即没有 `this.` ），它被认为一个状态变量。 如果使用外部访问（即用 `this.` ），它被认作为一个函数。

```
pragma solidity >=0.4.16 <0.9.0;

contract C {
    uint public data;
    function x() public {
        data = 3; // 内部访问
        uint val = this.data(); // 外部访问
    }
}
```

如果你有一个数组类型的 `public` 状态变量，那么你只能通过生成的 getter 函数访问数组的单个元素。 这个机制以避免返回整个数组时的高成本gas。 可以使用如 `myArray(0)` 用于指定参数要返回的单个元素。 如果要在一次调用中返回整个数组，则需要写一个函数，例如：

```
pragma solidity >=0.4.0 <0.9.0;

contract arrayExample {
  // public state variable
  uint[] public myArray;

  // 指定生成的Getter 函数
  /*
  function myArray(uint i) public view returns (uint) {
      return myArray[i];
  }
  */

  // 返回整个数组
  function getArray() public view returns (uint[] memory) {
      return myArray;
  }
}
```

现在可以使用 `getArray()` 获得整个数组，而 `myArray(i)` 是返回单个元素。
