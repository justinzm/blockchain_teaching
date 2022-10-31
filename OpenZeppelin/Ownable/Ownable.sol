// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "Context.sol";

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