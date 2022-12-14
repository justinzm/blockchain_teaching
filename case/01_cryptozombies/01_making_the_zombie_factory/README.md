## 搭建僵尸工厂

### 创建合约

为了建立我们的僵尸部队， 让我们先建立一个基础合约，称为 `ZombieFactory`。

1. 在右边的输入框里输入 `0.8`，我们的合约基于这个版本的编译器。
2. 建立一个空合约 `ZombieFactory`。

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract ZombieFactory {

}
```

我们的僵尸DNA将由一个十六位数字组成。

定义 `dnaDigits` 为 `uint` 数据类型, 并赋值 `16`。

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract ZombieFactory {
	uint dnaDigits = 16;
}
```

为了保证我们的僵尸的DNA只含有16个字符，我们先造一个`uint`数据，让它等于10^16。这样一来以后我们可以用模运算符 `%` 把一个整数变成16位。

建立一个`uint`类型的变量，名字叫`dnaModulus`, 令其等于 **10 的 `dnaDigits` 次方**.

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract ZombieFactory {
	uint dnaDigits = 16;
	uint dnaModulus = 10 ** dnaDigits;
}
```

在我们的程序中，我们将创建一些僵尸！每个僵尸将拥有多个属性，所以这是一个展示结构体的完美例子。

1. 建立一个`struct` 命名为 `Zombie`.
2. 我们的 `Zombie` 结构体有两个属性： `name` (类型为 `string`), 和 `dna` (类型为 `uint`)。

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract ZombieFactory {
	uint dnaDigits = 16;
	uint dnaModulus = 10 ** dnaDigits;
	
	struct Zombie {
        string name;
        uint dna;
    }
}
```

为了把一个僵尸部队保存在我们的APP里，并且能够让其它APP看到这些僵尸，我们需要一个公共数组。

创建一个数据类型为 `Zombie` 的结构体数组，用 `public` 修饰，命名为：`zombies`.

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract ZombieFactory {
	uint dnaDigits = 16;
	uint dnaModulus = 10 ** dnaDigits;
	
	struct Zombie {
        string name;
        uint dna;
    }
    
    Zombie[] public zombies;
}
```

在我们的应用里，我们要能创建一些僵尸，让我们写一个函数做这件事吧！

建立一个函数 `createZombie`。 它有两个参数: **_name** (类型为`string`), 和 **_dna** (类型为`uint`)。

1. 在函数体里新创建一个 `Zombie`， 然后把它加入 `zombies` 数组中。 新创建的僵尸的 `name` 和 `dna`，来自于函数的参数。
2. 让我们用一行代码简洁地完成它。
3. 我们合约的函数 `createZombie` 的默认属性是公共的，这意味着任何一方都可以调用它去创建一个僵尸。 咱们来把它变成私有吧！

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract ZombieFactory {
	uint dnaDigits = 16;
	uint dnaModulus = 10 ** dnaDigits;
	
	struct Zombie {
        string name;
        uint dna;
    }
    
    Zombie[] public zombies;
    
    function _createZombie(string _name, uint _dna) private {
        zombies.push(Zombie(_name, _dna));
    }
}
```

我们想建立一个帮助函数，它根据一个字符串随机生成一个DNA数据。

1. 创建一个 `private` 函数，命名为 `_generateRandomDna`。它只接收一个输入变量 `_str` (类型 `string`), 返回一个 `uint` 类型的数值。
2. 此函数只读取我们合约中的一些变量，所以标记为`view`。
3. 第一行代码取 `_str` 的 `keccak256` 散列值生成一个伪随机十六进制数，类型转换为 `uint`, 最后保存在类型为 `uint` 名为 `rand` 的变量中。
4. 我们只想让我们的DNA的长度为16位 (还记得 `dnaModulus`)。所以第二行代码应该 `return` 上面计算的数值对 `dnaModulus` 求余数(`%`)。

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract ZombieFactory {
	uint dnaDigits = 16;
	uint dnaModulus = 10 ** dnaDigits;
	
	struct Zombie {
        string name;
        uint dna;
    }
    
    Zombie[] public zombies;
    
    function _createZombie(string _name, uint _dna) private {
        zombies.push(Zombie(_name, _dna));
    }
    
    // 创建僵尸DNA
    function _generateRandomDna(string memory _str) private view returns(uint){
        uint rand = uint(keccak256(abi.encode(_str)));
        return rand % dnaModulus;
    }
}
```

1. 创建一个 `public` 函数，命名为 `createRandomZombie`. 它将被传入一个变量 `_name` (数据类型是 `string`)。 *(注: 定义公共函数 `public` 和定义一个私有 `private` 函数的做法一样)*。
2. 函数的第一行应该调用 `_generateRandomDna` 函数，传入 `_name` 参数, 结果保存在一个类型为 `uint` 的变量里，命名为 `randDna`。
3. 第二行调用 `_createZombie` 函数， 传入参数： `_name` 和 `randDna`。

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract ZombieFactory {
	uint dnaDigits = 16;
	uint dnaModulus = 10 ** dnaDigits;
	
	struct Zombie {
        string name;
        uint dna;
    }
    
    Zombie[] public zombies;
    
    function _createZombie(string _name, uint _dna) private {
        zombies.push(Zombie(_name, _dna));
    }
    
    // 创建僵尸DNA
    function _generateRandomDna(string memory _str) private view returns(uint){
        uint rand = uint(keccak256(abi.encode(_str)));
        return rand % dnaModulus;
    }
    
    //创建僵尸 公共函数
    function createRandomZombie(string memory _name) public {
        require(ownerZombieCount[msg.sender] == 0);
        uint randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
    }
}
```

我们想每当一个僵尸创造出来时，我们的前端都能监听到这个事件，并将它显示出来。

1。 定义一个 `事件` 叫做 `NewZombie`。 它有3个参数: `zombieId` (`uint`)， `name` (`string`)， 和 `dna` (`uint`)。

2。 修改 `_createZombie` 函数使得当新僵尸造出来并加入 `zombies`数组后，生成事件`NewZombie`。

3。 需要定义僵尸`id`。 `array.push()` 返回数组的长度类型是`uint` - 因为数组的第一个元素的索引是 0， `array.push() - 1` 将是我们加入的僵尸的索引。 `zombies.push() - 1` 就是 `id`，数据类型是 `uint`。在下一行中你可以把它用到 `NewZombie` 事件中。

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract ZombieFactory {
	uint dnaDigits = 16;
	uint dnaModulus = 10 ** dnaDigits;
	
	struct Zombie {
        string name;
        uint dna;
    }
    
    Zombie[] public zombies;
    
    event NewZombie (uint zombieId, string name, uint dna);
    
    function _createZombie(string _name, uint _dna) private {
        zombies.push(Zombie(_name, _dna));
        uint id = zombies.length + 1;
        emit NewZombie(id, _name, _dna);
    }
    
    // 创建僵尸DNA
    function _generateRandomDna(string memory _str) private view returns(uint){
        uint rand = uint(keccak256(abi.encode(_str)));
        return rand % dnaModulus;
    }
    
    //创建僵尸 公共函数
    function createRandomZombie(string memory _name) public {
        require(ownerZombieCount[msg.sender] == 0);
        uint randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
    }
}
```

