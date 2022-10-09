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