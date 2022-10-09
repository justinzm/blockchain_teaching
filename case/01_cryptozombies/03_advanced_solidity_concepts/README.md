## 高级 Solidity 理论

将 `Ownable` 合约的代码复制一份到新文件 `ownable.sol` 中。 接下来，创建一个 `ZombieFactory`，继承 `Ownable`。

1.在程序中导入 `ownable.sol` 的内容。 

2.修改 `ZombieFactory` 合约， 让它继承自 `Ownable`。 

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import './Ownable.sol';

contract ZombieFactory is Ownable {
    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;

    ……
} 
```

现在我们可以限制第三方对 `setKittyContractAddress`的访问，除了我们自己，谁都无法去修改它。

将 `onlyOwner` 函数修饰符添加到 `setKittyContractAddress` 中。

```
function setKittyContractAddress(address _address) external onlyOwner {
	kittyContract = KittyInterface(_address);
}
```

咱们给僵尸添2个新功能：`level` 和 `readyTime` - 后者是用来实现一个“冷却定时器”，以限制僵尸猎食的频率。

让我们回到 `zombiefactory.sol`。

为 `Zombie` 结构体 添加两个属性：`level`（`uint32`）和`readyTime`（`uint32`）。因为希望同类型数据打成一个包，所以把它们放在结构体的末尾。

32位足以保存僵尸的级别和时间戳了，这样比起使用普通的`uint`（256位），可以更紧密地封装数据，从而为我们省点 gas。

```
contract ZombieFactory is Ownable {
    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;

    struct Zombie {
        string name;
        uint dna;
        uint32 level;
        uint32 readyTime;
    }
    ……
```

现在咱们给DApp添加一个“冷却周期”的设定，让僵尸两次攻击或捕猎之间必须等待 **1天**。

1. 声明一个名为 `cooldownTime` 的`uint`，并将其设置为 `1 days`。（没错，”1 days“使用了复数， 否则通不过编译器）

2. 因为在上一章中我们给 `Zombie` 结构体中添加 `level` 和 `readyTime` 两个参数，所以现在创建一个新的 `Zombie` 结构体时，需要修改 `_createZombie()`，在其中把新旧参数都初始化一下。

   修改 `zombies.push` 那一行， 添加加2个参数：`1`（表示当前的 `level` ）和`uint32（block.timestamp + cooldownTime）`（现在+冷却时间，表示下次允许攻击的时间 `readyTime`）。

> 注意：必须使用 `uint32（...）` 进行强制类型转换，因为 `now` 返回类型 `uint256`。所以我们需要明确将它转换成一个 `uint32` 类型的变量。

`block.timestamp + cooldownTime` 将等于当前的unix时间戳（以秒为单位）加上”1天“里的秒数 - 这将等于从现在起1天后的unix时间戳。然后我们就比较，看看这个僵尸的 `readyTime`是否大于 `now`，以决定再次启用僵尸的时机有没有到来。

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import './Ownable.sol';

contract ZombieFactory is Ownable {
    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;

    uint cooldownTime = 1 days;

    struct Zombie {
        string name;
        uint dna;
        uint32 level;
        uint32 readyTime;
    }

    ……

    // 创建僵尸
    function _createZombie(string memory _name, uint _dna) internal {
        zombies.push(Zombie(_name, _dna, 1, uint32(block.timestamp + cooldownTime)));
        uint id = zombies.length + 1;
        emit NewZombie(id, _name, _dna);
        zombieToOwner[id] = msg.sender;
        ownerZombieCount[msg.sender]++;
    }

    ……
} 
```

现在，`Zombie` 结构体中定义好了一个 `readyTime` 属性，让我们跳到 `zombiefeeding.sol`， 去实现一个”冷却周期定时器“。

按照以下步骤修改 `feedAndMultiply`：

1. ”捕猎“行为会触发僵尸的”冷却周期“
2. 僵尸在这段”冷却周期“结束前不可再捕猎小猫

这将限制僵尸，防止其无限制地捕猎小猫或者整天不停地繁殖。将来，当我们增加战斗功能时，我们同样用”冷却周期“限制僵尸之间打斗的频率。

首先，我们要定义一些辅助函数，设置并检查僵尸的 `readyTime`。

1. 先定义一个 `_triggerCooldown` 函数。它要求一个参数，`_zombie`，表示一某个僵尸的存储指针。这个函数可见性设置为 `internal`。
2. 在函数中，把 `_zombie.readyTime` 设置为 `uint32（block.timestamp + cooldownTime）`。
3. 接下来，创建一个名为 `_isReady` 的函数。这个函数的参数也是名为 `_zombie` 的 `Zombie storage`。这个功能只具有 `internal` 可见性，并返回一个 `bool` 值。
4. 函数计算返回`(_zombie.readyTime <= now)`，值为 `true` 或 `false`。这个功能的目的是判断下次允许猎食的时间是否已经到了

```
contract ZombieFeeding is ZombieFactory {
    KittyInterface kittyContract;

    function setKittyContractAddress(address _address) external onlyOwner {
        kittyContract = KittyInterface(_address);
    }

    function _triggerCooldown(Zombie storage _zombie) internal{
        _zombie.readyTime = uint32(block.timestamp + cooldownTime);
    }

    function _isReady(Zombie storage _zombie) internal view returns(bool){
        return (_zombie.readyTime <= block.timestamp);
    }
	
	……
    
}
```

现在来修改 `feedAndMultiply` ，实现冷却周期

1. 目前函数 `feedAndMultiply` 可见性为 `public`。我们将其改为 `internal` 以保障合约安全。因为我们不希望用户调用它的时候塞进一堆乱七八糟的 DNA。
2. `feedAndMultiply` 过程需要参考 `cooldownTime`。首先，在找到 `myZombie` 之后，添加一个 `require` 语句来检查 `_isReady()` 并将 `myZombie` 传递给它。这样用户必须等到僵尸的 `冷却周期` 结束后才能执行 `feedAndMultiply` 功能。
3. 在函数结束时，调用 `_triggerCooldown(myZombie)`，标明捕猎行为触发了僵尸新的冷却周期。

```


contract ZombieFeeding is ZombieFactory {

    KittyInterface kittyContract;

    function setKittyContractAddress(address _address) external onlyOwner {
        kittyContract = KittyInterface(_address);
    }

    function _triggerCooldown(Zombie storage _zombie) internal{
        _zombie.readyTime = uint32(block.timestamp + cooldownTime);
    }

    function _isReady(Zombie storage _zombie) internal view returns(bool){
        return (_zombie.readyTime <= block.timestamp);
    }

    function feedAndMultiply(uint _zombieId, uint _targetDna, string memory _species) internal {
        require(msg.sender == zombieToOwner[_zombieId]);
        Zombie storage myZombie = zombies[_zombieId];
        require(_isReady(myZombie));
        _targetDna = _targetDna % dnaModulus;
        uint newDna = (myZombie.dna + _targetDna) / 2;
        if (keccak256(abi.encode(_species)) == keccak256(abi.encode("kitty"))) {
            newDna = newDna - newDna % 100 + 99;
        }
        _createZombie("NoName", newDna);
        _triggerCooldown(myZombie);
    }

    ……
}
```

我们的僵尸现在有了“冷却定时器”功能。

接下来，我们将添加一些辅助方法。我们为您创建了一个名为 `zombiehelper.sol` 的新文件，并且将 `zombiefeeding.sol` 导入其中，这让我们的代码更整洁。

我们打算让僵尸在达到一定水平后，获得特殊能力。

1. 在`ZombieHelper` 中，创建一个名为 `aboveLevel` 的`modifier`，它接收2个参数， `_level` (`uint`类型) 以及 `_zombieId` (`uint`类型)。
2. 运用函数逻辑确保僵尸 `zombies[_zombieId].level` 大于或等于 `_level`。
3. 记住，修饰符的最后一行为 `_;`，表示修饰符调用结束后返回，并执行调用函数余下的部分。

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "./ZombieFeeding.sol";

contract ZombieHelper is ZombieFeeding{
    modifier aboveLevel(uint _level, uint _zombieId){
        require(zombies[_zombieId].level >= _level);
        _;
    }
}
```

现在让我们设计一些使用 `aboveLevel` 修饰符的函数。

作为游戏，您得有一些措施激励玩家们去升级他们的僵尸：

- 2级以上的僵尸，玩家可给他们改名。
- 20级以上的僵尸，玩家能给他们定制的 DNA。

是实现这些功能的时候了。以下是上一课的示例代码，供参考：

```
// 存储用户年龄的映射
mapping (uint => uint) public age;

// 限定用户年龄的修饰符
modifier olderThan(uint _age, uint _userId) {
  require (age[_userId] >= _age);
  _;
}

// 必须年满16周岁才允许开车
// 我们可以用如下参数调用`olderThan` 修饰符:
function driveCar(uint _userId) public olderThan(16, _userId) {
  // 其余的程序逻辑
}
```

1. 创建一个名为 `changeName` 的函数。它接收2个参数：`_zombieId`（`uint`类型）以及 `_newName`（`string`类型），可见性为 `external`。它带有一个 `aboveLevel` 修饰符，调用的时候通过 `_level` 参数传入`2`， 当然，别忘了同时传 `_zombieId` 参数。
2. 在这个函数中，首先我们用 `require` 语句，验证 `msg.sender` 是否就是 `zombieToOwner [_zombieId]`。
3. 然后函数将 `zombies[_zombieId].name` 设置为 `_newName`。
4. 在 `changeName` 下创建另一个名为 `changeDna` 的函数。它的定义和内容几乎和 `changeName` 相同，不过它第二个参数是 `_newDna`（`uint`类型），在修饰符 `aboveLevel` 的 `_level` 参数中传递 `20` 。现在，他可以把僵尸的 `dna` 设置为 `_newDna` 了。

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "./ZombieFeeding.sol";

contract ZombieHelper is ZombieFeeding{
    modifier aboveLevel(uint _level, uint _zombieId){
        require(zombies[_zombieId].level >= _level);
        _;
    }

    function changeName(uint _zombieId, string memory _newName) external aboveLevel(2, _zombieId){
        require(msg.sender == zombieToOwner[_zombieId]);
        zombies[_zombieId].name = _newName;
    }

    function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId){
        require(msg.sender == zombieToOwner[_zombieId]);
        zombies[_zombieId].dna = _newDna;
    }
}
```

现在高级别僵尸可以拥有特殊技能了，这一定会鼓动我们的玩家去打怪升级的。你喜欢的话，回头我们还能添加更多的特殊技能。

现在需要添加的一个功能是：我们的 DApp 需要一个方法来查看某玩家的整个僵尸军团 - 我们称之为 `getZombiesByOwner`。

实现这个功能只需从区块链中读取数据，所以它可以是一个 `view` 函数。

我们来写一个”返回某玩家的整个僵尸军团“的函数。当我们从 `web3.js` 中调用它，即可显示某一玩家的个人资料页。

这个函数的逻辑有点复杂，我们需要好几个章节来描述它的实现。

1. 创建一个名为 `getZombiesByOwner` 的新函数。它有一个名为 `_owner` 的 `address` 类型的参数。
2. 将其申明为 `external view` 函数，这样当玩家从 `web3.js` 中调用它时，不需要花费任何 gas。
3. 声明一个名为`result`的`uint [] memory'` （内存变量数组）
4. 将其设置为一个新的 `uint` 类型数组。数组的长度为该 `_owner` 所拥有的僵尸数量，这可通过调用 `ownerZombieCount [_ owner]` 来获取。
5. 函数结束，返回 `result` 。目前它只是个空数列，我们到下一章去实现它。

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "./ZombieFeeding.sol";

contract ZombieHelper is ZombieFeeding{
    modifier aboveLevel(uint _level, uint _zombieId){
        require(zombies[_zombieId].level >= _level);
        _;
    }

    function changeName(uint _zombieId, string memory _newName) external aboveLevel(2, _zombieId){
        require(msg.sender == zombieToOwner[_zombieId]);
        zombies[_zombieId].name = _newName;
    }

    function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId){
        require(msg.sender == zombieToOwner[_zombieId]);
        zombies[_zombieId].dna = _newDna;
    }

    function getZombiesByOwner(address _owner) external view returns(uint[] memory){
        uint[] memory result = new uint[](ownerZombieCount[_owner]);
        // 在这里开始
        return result;
    }
}
```

回到 `getZombiesByOwner` 函数， 通过一条 `for` 循环来遍历 DApp 中所有的僵尸， 将给定的‘用户id'与每头僵尸的‘主人’进行比较，并在函数返回之前将它们推送到我们的`result` 数组中。

1.声明一个变量 `counter`，属性为 `uint`，设其值为 `0` 。我们用这个变量作为 `result` 数组的索引。

2.声明一个 `for` 循环， 从 `uint i = 0` 到 `i <zombies.length`。它将遍历数组中的每一头僵尸。

3.在每一轮 `for` 循环中，用一个 `if` 语句来检查 `zombieToOwner [i]` 是否等于 `_owner`。这会比较两个地址是否匹配。

4.在 `if` 语句中：

1. 通过将 `result [counter]` 设置为 `i`，将僵尸ID添加到 `result` 数组中。
2. 将counter加1（参见上面的for循环示例）。

就是这样 - 这个函数能返回 `_owner` 所拥有的僵尸数组，不花一分钱 gas。

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "./ZombieFeeding.sol";

contract ZombieHelper is ZombieFeeding{
    modifier aboveLevel(uint _level, uint _zombieId){
        require(zombies[_zombieId].level >= _level);
        _;
    }

    function changeName(uint _zombieId, string memory _newName) external aboveLevel(2, _zombieId){
        require(msg.sender == zombieToOwner[_zombieId]);
        zombies[_zombieId].name = _newName;
    }

    function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId){
        require(msg.sender == zombieToOwner[_zombieId]);
        zombies[_zombieId].dna = _newDna;
    }

    function getZombiesByOwner(address _owner) external view returns(uint[] memory){
        uint[] memory result = new uint[](ownerZombieCount[_owner]);
        uint counter = 0;
        for (uint i = 0; i < zombies.length; i++) {
            if (zombieToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }
}
```

