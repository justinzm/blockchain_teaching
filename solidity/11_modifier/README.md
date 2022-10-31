### 函数修改器

修改器（modifier），可以用来轻易的改变一个函数的行为，控制函数的逻辑，比如用于在函数执行前检查某种前置条件

修改器是一种合约属性，可以被继承，同时还可被派生的合约重写（override）

关键字：**modifier**

格式：

```
modifier 函数修改器名(参数){
	a++;	// 代表函数前执行的代码
	_;		// 表示被修饰的函数中的代码
	a--;	// 代表函数后执行的代码
}
```

对于一个函数可以有多个修改器限制，在函数定义的时候依次写上，并用加空格分隔，执行的时候也是依次执行，多个修改器是同时限制，也就是说必须满足所有修改器的权限，才可以执行函数体的代码。

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract FunctionModifier {
    // We will use these variables to demonstrate how to use
    // modifiers.
    address public owner;
    uint public x = 10;
    bool public locked;

    constructor() {
        // Set the transaction sender as the owner of the contract.
        owner = msg.sender;
    }

    // Modifier to check that the caller is the owner of
    // the contract.
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        // Underscore is a special character only used inside
        // a function modifier and it tells Solidity to
        // execute the rest of the code.
        _;
    }

    // Modifiers can take inputs. This modifier checks that the
    // address passed in is not the zero address.
    modifier validAddress(address _addr) {
        require(_addr != address(0), "Not valid address");
        _;
    }

    function changeOwner(address _newOwner) public onlyOwner validAddress(_newOwner) {
        owner = _newOwner;
    }

    // Modifiers can be called before and / or after a function.
    // This modifier prevents a function from being called while
    // it is still executing.
    modifier noReentrancy() {
        require(!locked, "No reentrancy");
        locked = true;
        _;
        locked = false;
    }

    function decrement(uint i) public noReentrancy {
        x -= i;
        if (i > 1) {
            decrement(i - 1);
        }
    }
}
```

如果同一个函数有多个 修饰器modifier，它们之间以空格隔开，修饰器modifier 会依次检查执行。

修饰器modifier 或函数体中显式的 return 语句仅仅跳出当前的 修饰器modifier 和函数体。 返回变量会被赋值，但整个执行逻辑会从前一个 修饰器modifier 中的定义的 “_” 之后继续执行。

修饰器modifier 的参数可以是任意表达式，在此上下文中，所有在函数中可见的符号，在 修饰器modifier 中均可见。 在 修饰器modifier 中引入的符号在函数中不可见（可能被重载改变）。