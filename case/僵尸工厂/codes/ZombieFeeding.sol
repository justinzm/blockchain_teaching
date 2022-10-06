// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import './ZombieFactory.sol';

constant ZombieFeeding is ZombieFactory {

    function feedAndMultiply(uint _zombieId, , uint _targetDna) public {
        require(msg.sender == zombieToOwner[_zombieId]);
        Zombie storage myZombie = zombies[_zombieId];

        _targetDna = _targetDna % dnaModulus;

        uint newDna = (myZombie.dna + _targetDna) / 2;
        _createZombie("NoName", newDna);
    }
}