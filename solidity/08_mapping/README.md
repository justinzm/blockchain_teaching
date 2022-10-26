### 映射/字典 mappings

`映射`或字典类型，一种键值对的映射关系存储结构。定义方式为`mapping(_KeyType => _KeyValue)`。键的类型允许除`映射`外的所有类型，如数组，合约，枚举，结构体。值的类型无限制。

`映射`可以被视作为一个哈希表，其中所有可能的键已被虚拟化的创建，被映射到一个默认值（二进制表示的零）。但在映射表中，我们并不存储键的数据，仅仅存储它的`keccak256`哈希值，用来查找值时使用。

因此，`映射`并没有长度，键集合（或列表），值集合（或列表）这样的概念。

在映射中，人们可以通过键（`Key`）来查询对应的值（`Value`），比如：通过一个人的`id`来查询他的钱包地址。

声明映射的格式为`mapping(_KeyType => _ValueType)`，其中`_KeyType`和`_ValueType`分别是`Key`和`Value`的变量类型。例子：

```
    mapping(uint => address) public idToAddress; // id映射到地址
    mapping(address => address) public swapPair; // 币对的映射，地址到地址
```

#### 映射的规则

- **规则1**：映射的`_KeyType`只能选择`solidity`默认的类型，比如`uint`，`address`等，不能用自定义的结构体。而`_ValueType`可以使用自定义的类型。下面这个例子会报错，因为`_KeyType`使用了我们自定义的结构体：

```
    // 我们定义一个结构体 Struct
    struct Student{
        uint256 id;
        uint256 score; 
    }
     mapping(Student => uint) public testVar;
```

- **规则2**：映射的存储位置必须是`storage`，因此可以用于合约的状态变量，函数中的`storage`变量，和library函数的参数（见[例子](https://github.com/ethereum/solidity/issues/4635)）。不能用于`public`函数的参数或返回结果中，因为`mapping`记录的是一种关系 (key - value pair)。
- **规则3**：如果映射声明为`public`，那么`solidity`会自动给你创建一个`getter`函数，可以通过`Key`来查询对应的`Value`。
- **规则4**：给映射新增的键值对的语法为`_Var[_Key] = _Value`，其中`_Var`是映射变量名，`_Key`和`_Value`对应新增的键值对。例子：

```
    function writeMap (uint _Key, address _Value) public{
        idToAddress[_Key] = _Value;
    }
```

可以通过将`映射`标记为`public`，来让Solidity创建一个访问器。要想访问这样的`映射`，需要提供一个键值做为参数。如果`映射`的值类型也是`映射`，使用访问器访问时，要提供这个`映射`值所对应的键，不断重复这个过程。下面来看一个例子：

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Mapping {
    // Mapping from address to uint
    mapping(address => uint) public myMap;

    function get(address _addr) public view returns (uint) {
        // Mapping always returns a value.
        // If the value was never set, it will return the default value.
        return myMap[_addr];
    }

    function set(address _addr, uint _i) public {
        // Update the value at this address
        myMap[_addr] = _i;
    }

    function remove(address _addr) public {
        // Reset the value to the default value.
        delete myMap[_addr];
    }
}

contract NestedMapping {
    // Nested mapping (mapping from address to another mapping)
    mapping(address => mapping(uint => bool)) public nested;

    function get(address _addr1, uint _i) public view returns (bool) {
        // You can get values from a nested mapping
        // even when it is not initialized
        return nested[_addr1][_i];
    }

    function set(
        address _addr1,
        uint _i,
        bool _boo
    ) public {
        nested[_addr1][_i] = _boo;
    }

    function remove(address _addr1, uint _i) public {
        delete nested[_addr1][_i];
    }
}
```

