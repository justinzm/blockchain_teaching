let Web3 = require('web3');
let web3 = new Web3(new Web3.providers.HttpProvider("HTTP://127.0.0.1:7545"));

web3.eth.getNodeInfo().then(console.log);

var abi = [
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_name",
				"type": "string"
			}
		],
		"name": "createRandomZombie",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "zombieId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "name",
				"type": "string"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "dna",
				"type": "uint256"
			}
		],
		"name": "NewZombie",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "zombies",
		"outputs": [
			{
				"internalType": "string",
				"name": "name",
				"type": "string"
			},
			{
				"internalType": "uint256",
				"name": "dna",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]

// 合约地址
var address = "0x42643cF3315923F2984057912199717E50aa4889";

// 智能合约
var contract = new web3.eth.Contract(abi, address);

console.log(contract);

var name = "justin"

contract.methods.createRandomZombie(name).call().then((res) => {
    console.log(res);
});

// 监听 `NewZombie` 事件, 并且更新UI
var event = contract.events.NewZombie(function(error, result) {
    console.log(error);
    console.log(result);
    // console.log(result.zombieId);
    // console.log(result.name);
    // console.log(result.dna);
})
