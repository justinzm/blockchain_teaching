// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Enum {
    // Enum representing shipping status
    enum Status {
        Pending,
        Shipped,
        Accepted,
        Rejected,
        Canceled
    }
    
    // 默认值为 类型的定义，在本例中为"Pending"
    Status public status;

    // Returns uint
    // Pending  - 0
    // Shipped  - 1
    // Accepted - 2
    // Rejected - 3
    // Canceled - 4
    function get() public view returns (Status) {
        return status;
    }

    // 通过将uint传入input来更新状态
    function set(Status _status) public {
        status = _status;
    }

    // 您可以像这样更新到特定的枚举
    function cancel() public {
        status = Status.Accepted;
    }

    // 删除 将枚举重置为它的第一个值0
    function reset() public {
        delete status;
    }
}