## 僵尸攻击人类

为了存储僵尸的所有权，我们会使用到两个映射：一个记录僵尸拥有者的地址，另一个记录某地址所拥有僵尸的数量。

1. 创建一个叫做 `zombieToOwner` 的映射。其键是一个`uint`（我们将根据它的 id 存储和查找僵尸），值为 `address`。映射属性为`public`。

2. 创建一个名为 `ownerZombieCount` 的映射，其中键是 `address`，值是 `uint`。

3. 在得到新的僵尸 `id` 后，更新 `zombieToOwner` 映射，在 `id` 下面存入 `msg.sender`。

4. 然后，我们为这个 `msg.sender` 名下的 `ownerZombieCount` 加 1。

在我们的僵尸游戏中，我们不希望用户通过反复调用 `createRandomZombie` 来給他们的军队创建无限多个僵尸 —— 这将使得游戏非常无聊。

我们使用了 `require` 来确保这个函数只有在每个用户第一次调用它的时候执行，用以创建初始僵尸。

在 `createRandomZombie` 的前面放置 `require` 语句。 使得函数先检查 `ownerZombieCount [msg.sender]` 的值为 `0` ，不然就抛出一个错误。

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

    // 映射 一个记录僵尸拥有者的地址
    mapping (uint => address) public zombieToOwner;
    // 某地址所拥有僵尸的数量
    mapping (address => uint) ownerZombieCount;

    Zombie[] public zombies;

    event NewZombie (uint zombieId, string name, uint dna);

    // 创建僵尸
    function _createZombie(string memory _name, uint _dna) internal {
        zombies.push(Zombie(_name, _dna));
        uint id = zombies.length + 1;
        emit NewZombie(id, _name, _dna);
        zombieToOwner[id] = msg.sender;
        ownerZombieCount[msg.sender]++;
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

我们将要为僵尸实现各种功能，让它可以“猎食”和“繁殖”。 通过将这些运算放到父类 `ZombieFactory` 中，使得所有 `ZombieFactory` 的继承者合约都可以使用这些方法。

在 `ZombieFactory` 下创建一个叫 `ZombieFeeding` 的合约，它是继承自 `ZombieFactory 合约的。

将 `zombiefactory.sol` 导入到我们的新文件 `zombiefeeding.sol` 中。

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "./ZombieFactory.sol";

contract ZombieFeeding is ZombieFactory {

}
```

是时候给我们的僵尸增加“猎食”和“繁殖”功能了！

当一个僵尸猎食其他生物体时，它自身的DNA将与猎物生物的DNA结合在一起，形成一个新的僵尸DNA。

1. 创建一个名为 `feedAndMultiply` 的函数。 使用两个参数：`_zombieId`（ `uint`类型 ）和`_targetDna` （也是 `uint` 类型）。 设置属性为 `public` 的。
2. 我们不希望别人用我们的僵尸去捕猎。 首先，我们确保对自己僵尸的所有权。 通过添加一个`require` 语句来确保 `msg.sender` 只能是这个僵尸的主人（类似于我们在 `createRandomZombie` 函数中做过的那样）。

3. 为了获取这个僵尸的DNA，我们的函数需要声明一个名为 `myZombie` 数据类型为`Zombie`的本地变量（这是一个 `storage` 型的指针）。 将其值设定为在 `zombies` 数组中索引为`_zombieId`所指向的值。

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "./ZombieFactory.sol";

contract ZombieFeeding is ZombieFactory {
	function feedAndMultiply(uint _zombieId, uint _targetDna) public {
    	require(msg.sender == zombieToOwner[_zombieId]);
    	Zombie storage myZombie = zombies[_zombieId];
    }
}
```

首先我们确保 `_targetDna` 不长于16位。要做到这一点，我们可以设置 `_targetDna` 为 `_targetDna ％ dnaModulus` ，并且只取其最后16位数字。

接下来为我们的函数声明一个名叫 `newDna` 的 `uint`类型的变量，并将其值设置为 `myZombie`的 DNA 和 `_targetDna` 的平均值（如上例所示）。

一旦我们计算出新的DNA，再调用 `_createZombie` 就可以生成新的僵尸了。如果你忘了调用这个函数所需要的参数，可以查看 `zombiefactory.sol` 选项卡。请注意，需要先给它命名，所以现在我们把新的僵尸的名字设为`NoName` - 我们回头可以编写一个函数来更改僵尸的名字。

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "./ZombieFactory.sol";

contract ZombieFeeding is ZombieFactory {
	function feedAndMultiply(uint _zombieId, uint _targetDna) public {
    	require(msg.sender == zombieToOwner[_zombieId]);
    	Zombie storage myZombie = zombies[_zombieId];
    	
    	_targetDna = _targetDna % dnaModulus;
        uint newDna = (myZombie.dna + _targetDna) / 2;
        _createZombie("NoName", newDna);
    }
}
```

我们已经为你查看过了 CryptoKitties 的源代码，并且找到了一个名为 `getKitty`的函数，它返回所有的加密猫的数据，包括它的“基因”（我们的僵尸游戏要用它生成新的僵尸）。

该函数如下所示：

```
function getKitty(uint256 _id) external view returns (
    bool isGestating,
    bool isReady,
    uint256 cooldownIndex,
    uint256 nextActionAt,
    uint256 siringWithId,
    uint256 birthTime,
    uint256 matronId,
    uint256 sireId,
    uint256 generation,
    uint256 genes
) {
    Kitty storage kit = kitties[_id];

    // if this variable is 0 then it's not gestating
    isGestating = (kit.siringWithId != 0);
    isReady = (kit.cooldownEndBlock <= block.number);
    cooldownIndex = uint256(kit.cooldownIndex);
    nextActionAt = uint256(kit.cooldownEndBlock);
    siringWithId = uint256(kit.siringWithId);
    birthTime = uint256(kit.birthTime);
    matronId = uint256(kit.matronId);
    sireId = uint256(kit.sireId);
    generation = uint256(kit.generation);
    genes = kit.genes;
}
```

这个函数看起来跟我们习惯的函数不太一样。 它竟然返回了...一堆不同的值！ 如果您用过 JavaScript 之类的编程语言，一定会感到奇怪 —— 在 Solidity中，您可以让一个函数返回多个值。

现在我们知道这个函数长什么样的了，就可以用它来创建一个接口：

1. 定义一个名为 `KittyInterface` 的接口。 请注意，因为我们使用了 `interface` 关键字， 这过程看起来就像创建一个新的合约一样。

2. 在interface里定义了 `getKitty` 函数（不过是复制/粘贴上面的函数，但在 `returns` 语句之后用分号，而不是大括号内的所有内容。

我们来建个自己的合约去读取另一个智能合约-- CryptoKitties 的内容吧！

我已经将代码中 CryptoKitties 合约的地址保存在一个名为 `ckAddress` 的变量中。在下一行中，请创建一个名为 `kittyContract` 的 KittyInterface，并用 `ckAddress` 为它初始化 —— 就像我们为 `numberContract`所做的一样。

是时候与 CryptoKitties 合约交互起来了！

我们来定义一个函数，从 kitty 合约中获取它的基因：

1. 创建一个名为 `feedOnKitty` 的函数。它需要2个 `uint` 类型的参数，`_zombieId` 和`_kittyId` ，这是一个 `public` 类型的函数。
2. 函数首先要声明一个名为 `kittyDna` 的 `uint`。
3. 这个函数接下来调用 `kittyContract.getKitty`函数, 传入 `_kittyId` ，将返回的 `genes` 存储在 `kittyDna` 中。记住 —— `getKitty` 会返回一大堆变量。但是我们只关心最后一个-- `genes`。数逗号的时候小心点哦！
4. 最后，函数调用了 `feedAndMultiply` ，并传入了 `_zombieId` 和 `kittyDna` 两个参数。

我们的功能逻辑主体已经完成了...现在让我们来添一个奖励功能吧。

这样吧，给从小猫制造出的僵尸添加些特征，以显示他们是猫僵尸。

要做到这一点，咱们在新僵尸的DNA中添加一些特殊的小猫代码。

1. 首先，我们修改下 `feedAndMultiply` 函数的定义，给它传入第三个参数：一条名为 `_species` 的字符串。

2. 接下来，在我们计算出新的僵尸的DNA之后，添加一个 `if` 语句来比较 `_species` 和字符串 `"kitty"` 的 `keccak256` 哈希值。

3. 在 `if` 语句中，我们用 `99` 替换了新僵尸DNA的最后两位数字。可以这么做：`newDna = newDna - newDna % 100 + 99;`。

   > 解释：假设 `newDna` 是 `334455`。那么 `newDna % 100` 是 `55`，所以 `newDna - newDna % 100` 得到 `334400`。最后加上 `99` 可得到 `334499`。

4. 最后，我们修改了 `feedOnKitty` 中的函数调用。当它调用 `feedAndMultiply` 时，增加 `“kitty”` 作为最后一个参数。

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "./ZombieFactory.sol";

interface KittyInterface {
  function getKitty(uint256 _id) external view returns (
    bool isGestating,
    bool isReady,
    uint256 cooldownIndex,
    uint256 nextActionAt,
    uint256 siringWithId,
    uint256 birthTime,
    uint256 matronId,
    uint256 sireId,
    uint256 generation,
    uint256 genes
  );
}

contract ZombieFeeding is ZombieFactory {
    KittyInterface kittyContract;

    function setKittyContractAddress(address _address) external {
        kittyContract = KittyInterface(_address);
    }

    function feedAndMultiply(uint _zombieId, uint _targetDna, string memory _species) public {
        require(msg.sender == zombieToOwner[_zombieId]);
        Zombie storage myZombie = zombies[_zombieId];

        _targetDna = _targetDna % dnaModulus;
        uint newDna = (myZombie.dna + _targetDna) / 2;

        if (keccak256(abi.encode(_species)) == keccak256(abi.encode("kitty"))) {
            newDna = newDna - newDna % 100 + 99;
        }
        _createZombie("NoName", newDna);
    }

    function feedOnKitty(uint _zombieId, uint _kittyId) public {
        uint kittyDna;
        (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
        // 并修改函数调用
        feedAndMultiply(_zombieId, kittyDna, "kitty");
    }
}
```

我们将加密小猫（CryptoKitties）合约的地址硬编码到 DApp 中去了。有没有想过，如果加密小猫出了点问题，比方说，集体消失了会怎么样？ 虽然这种事情几乎不可能发生，但是，如果小猫没了，我们的 DApp 也会随之失效 -- 因为我们在 DApp 的代码中用“硬编码”的方式指定了加密小猫的地址，如果这个根据地址找不到小猫，我们的僵尸也就吃不到小猫了，而按照前面的描述，我们却没法修改合约去应付这个变化！

因此，我们不能硬编码，而要采用“函数”，以便于 DApp 的关键部分可以以参数形式修改。

比方说，我们不再一开始就把猎物地址给写入代码，而是写个函数 `setKittyContractAddress`, 运行时再设定猎物的地址，这样我们就可以随时去锁定新的猎物，也不用担心加密小猫集体消失了。
