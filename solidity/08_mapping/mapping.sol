// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Mapping {
    // 创建映射 地址到uint
    mapping(address => uint) public myMap;

    function get(address _addr) public view returns (uint) {
        // 映射返回一个uint值，如果该值从未设置，则返回默认值
        return myMap[_addr];
    }

    function set(address _addr, uint _i) public {
        // 更新此地址的值
        myMap[_addr] = _i;
    }

    function remove(address _addr) public {
        // 将该值重置为默认值
        delete myMap[_addr];
    }
}

contract NestedMapping {
    // 嵌套映射(从地址映射到另一个映射)
    mapping(address => mapping(uint => bool)) public nested;

    function get(address _addr1, uint _i) public view returns (bool) {
        // 可以从嵌套映射中获取值; 即使它没有初始化
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