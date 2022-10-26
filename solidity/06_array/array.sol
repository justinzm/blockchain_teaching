// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Array {
    // Several ways to initialize an array
    uint[] public arr;
    uint[] public arr2 = [1, 2, 3];
    // 固定大小的数组，所有元素初始化为0
    uint[10] public myFixedSizeArr;

    function get(uint i) public view returns (uint) {
        return arr[i];
    }

    // Solidity可以返回整个数组；但是这个函数应该避免；数组的长度可以无限增长
    function getArr() public view returns (uint[] memory) {
        return arr;
    }

    // 添加到数组；这将使数组长度增加1。
    function push(uint i) public {
        arr.push(i);
    }

    // 从数组中删除最后一个元素；这将使数组长度减少1
    function pop() public {
        arr.pop();
    }

    // 获取数组长度
    function getLength() public view returns (uint) {
        return arr.length;
    }

    // 删除数组中的对应值，不改变数组长度，index的值重置为默认值0
    function remove(uint index) public {
        delete arr[index];
    }

    // 在内存中创建数组，只能创建固定大小的数组
//     function examples() external {
//         uint[5] memory a = new uint[](5);
//     }
}