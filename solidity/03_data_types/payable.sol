// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract Payable {
    // 可支付地址可以接收以太币
    address payable public owner;

    // 可支付的构造函数可以接收以太币
    constructor() payable {
        owner = payable(msg.sender);
    }

    //将账户中的value以太币转移到合同中
    function deposit() public payable {}

    //调用此函数时同时调用一些Ether；该函数将抛出一个错误，因为该函数是不可支付的。
    function notPayable() public {}

    // 把合约中的以太币转移到执行账户中
    function withdraw() public {
        // 获取该合同中存储的以太币数量
        uint amount = address(this).balance;

        (bool success, ) = owner.call{value: amount}("");
        require(success, "Failed to send Ether");
    }

    // 将合同中的以太币转移到输入地址中
    function transfer(address payable _to, uint _amount) public {
        // “to”被声明为应付款项
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Failed to send Ether");
    }

    // 该合约向指定账户地址已transfer方式发送以太币
    function getTransfer(address payable _addr, uint _amount) public {
        _addr.transfer(_amount);
    }
}