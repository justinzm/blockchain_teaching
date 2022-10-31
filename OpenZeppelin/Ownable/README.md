### 访问控制

该目录提供了限制谁可以访问合约功能或何时可以访问的方法。

- {AccessControl} 提供了一个通用的基于角色的访问控制机制。可以创建多个分层角色并将每个角色分配给多个帐户。
- {Ownable} 是一种更简单的机制，具有可以分配给单个帐户的单个所有者“角色”。这种更简单的机制对于快速测试很有用，但有生产问题的项目可能会超过它。

#### Context.sol

```
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
```

返回消息的发送方地址：msg.sender

返回完整的calldata：msg.data

#### Ownable.sol

```
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
 
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev 构造函数 将部署者设置为初始所有者。
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev 修饰 如果发送方不是所有者，则抛出。
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev 返回当前所有者的地址
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev 如果发送方不是所有者，则抛出。
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev 离开没有所有者的合同。将无法再调用 onlyOwner函数。只能由当前所有者调用。
     * NOTE: 放弃所有权将使合同没有所有者，从而删除仅所有者可用的任何功能。
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev 将合约的所有权转移到一个新账户 ( newOwner)。只能由当前所有者调用。
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev 将合约的所有权转移到一个新账户 ( newOwner)。内部功能无访问限制。
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
```

注意在构造函数中如何设置合约的owner账号。当Ownable的子合约（即继承Ownable的合约）初始化时，部署的账号就会设置为`_owner`。

下面是一个简单的、继承自Ownable的合约：

```
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";

contract OwnableContract is Ownable {

  function restrictedFunction() public view onlyOwner returns (uint) {
    return 200;
  }

  function openFunction() public pure returns (uint) {
    return 400;
  }
}
```

通过添加`onlyOwner` 修饰器来限制 `restrictedFunction` 函数合约的owner账号可以成功调用



