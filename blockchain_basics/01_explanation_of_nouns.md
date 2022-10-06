区块链就是建立在朴实无华的基本技术之上，一点也不神奇。虽然最近各种ICO把它炒得非常热。每个人都是站在巨人的肩膀上，如果你是程序员，你能对这些项目和技术，理解得更深。所以不要因为其它一些糟粕，而失去了一个提升自己的机会。

## 以太坊

[以太坊，Ethereum](https://www.ethereum.org/)是一个分布式的计算机，有许多的节点，其中的每一个节点，都会执行字节码（其实就是智能合约），然后把结果存在区块链上。由于整个网络是分布式的，且应用就是一个个的状态组成，存储了状态就有了服务；所以它就能永不停机，没有一个中心化的结点（没有任何一个节点说了算，去中心化的），任何第三方不能干预。

显然上面这一段话，直接解释了以太坊是什么。但你可能有非常多的问题。可以先读一下[以太坊的白皮书](https://github.com/ethereum/wiki/wiki/White-Paper)。或者看下这个视频，[25分钟理解以太坊](https://www.youtube.com/watch?v=66SaEDzlmP4)。（译者注：以太坊入门，确实没有什么好的办法，就是看白皮书最好，最快）

## 智能合约

智能合约与平时的代码其实没有什么区别，只是运行于一个以太坊这样的分布式平台上而已。这个运行的平台，赋予了这些代码不可变，确定性，分布式和可自校验状态等特点。代码运行过程中状态的存储，是不可变的。每一个人，都可以开一个自己的节点，重放整个区块链，将会获得同样的结果（译者注：能控制所有节点都达到一致状态，就是所谓的共识）。

在以太坊中，每个合约都有一个唯一的地址来标识它自己（由创建者的哈希地址和曾经发送过的交易的数量推算出来）。客户端可以与这个地址进行交互，可以发送ether，调用函数，查询当前的状态等。

智能合约，本质上来说就是代码，以及代码运行后存储到区块链上的状态两个元素组成。比如，你用来收发ETH的钱包，本质上就是一个智能合约，只是外面套了一个界面。

概念非常强大，而我相信你已经看完了。而你在看相关的新闻，经常听到这个非常有潜力，经常听到资产/权利管理，分权自治组织（DAO），身份，社交网络等炫酷。但他本质就是这些。

## Gas

智能合约，就是一些代码，运行整个分布式网络中。由于网络中的每一个节点都是一个全节点。这样的好处是容错性强，坏处是效率低，消耗资源与时间（译者注：原来只在一个节点执行一次就行，现在所有节点中每一个，都要执行一模一样的运算）。因为执行计算要花钱，而要执行的运算量与代码直接相关。所以，每个在网络运行的底层操作都需要一定量的`gas`。`gas`只是一个名字，它代表的是执行所需要花费的成本（译者注：由于以太坊是图灵完备的，随便一个死循环就将导致网络不可用，所以引入了`gas`的概念）。整个分布式网络引入了强制限制，来避免[停机问题](https://en.wikipedia.org/wiki/Halting_problem)。因此如果你写一个死循环，当`gas`耗尽后，网络就会拒绝执行接下来的操作，并且回滚你之前的所有操作。

`gas`的价格由市场决定，类似于比特币的交易费机制。如果你的`gas`价格高，节点则将优先因为利益问题打包你的交易。

一般来说，在Ethereum中计算和存储东西比在传统环境中做的更为昂贵，但是，Ethereum为您的代码提供了上述我们讨论过的那些好的属性，这可能是一样有价值的。

一般来说，在以太坊网上读取状态是免费的，只有写入状态是收费的。下面这个文章是`gas`概念的一些[深度解析](https://hackernoon.com/ether-purchase-power-df40a38c5a2f)。

## 分布式APP（ĐApp / Dapp / dapp/ dApp）

一个分布式App是指，服务端运行于以太坊网络上一个或多个智能合约。

一个分布式的App不用将所有状态都存储在区块链上，或者在链上进行所有计算（译者注：比如图形渲染），这样就太花`gas`了。所以一个分布式App把需要大家共同信任的状态存在区块链上就好了。许多的分布式应用使用后面提到的技术，如IPFS和Gelem，在链下进行分布式存储和计算。虽然没在以太坊上，但仍使用的是区块链技术。

我不知道谁开始在D上使用这个小小的缺点，是看起来酷，但会影响搜索。 你可以自由使用，但尽量方便别人的搜索。

以太坊的github上，有一个[dapp-bin的目录](https://github.com/ethereum/dapp-bin)，有一些文档和示例。使用前，你需要看看文件最近的状态，因为他们将很可能已经被淘汰。

## DApp客户端

大多数的分布式应用都通过一些用户友好的前端提供服务，因为不是所有人都愿意通过命令行，通过自己手动组装哈希串和操作指令码进行交易。

一个DApp与传统的开发中的，客户端或前端是类似，区别仅在于它们与以太坊的区块链进行交互（也可以同时与其它服务交互）。这些客户端往往用JS编写，因为当前还暂时没有完成全部的向NodeJS的转换。

另外，大多数的Dapp客户端使用JS的原因，是因为它可以在浏览器中运行，因为大家都有浏览器，这样每个人都可以运行了。由于有更多的go语言的开发工具，使用go语言来写客户端的也不少。在现在这个激烈的发展期，这意味着，除非你有自己的偏好，否则可能要从go和JS（也许还有，Rust）来选择一种语言，来与以太坊区块链，以及基于以太坊开发的协议进行交互了。

以太坊的一个核心开发者，[写了一篇关于使用Meteor工具来创建Dapp的文章](https://github.com/ethereum/wiki/wiki/Dapp-using-Meteor)，这意味着Meteor已经成为Dapp客户端开发的新标准。这绝对是基于JS建立全栈应用时的一个首选方法。但需要注意的是Meteor只是提供了一个开发工具，与DApp客户端并不等同，DApp客户端也完全可以由其它方式开发。（译者注：还有一些其它的开发工具，如Truffle，也是非常不错的哦）。

因为围绕Meteor和DApp开发的活跃，有非常多的包在`Atmophere（Meteor的包管理工具）`，它提供了许多常见的操作，如帐户管理，从区块链中获得最新的50个区块等等。

## DApp浏览器

一个DApp浏览器，正如它字面所表达的，用来让DApp客户端（常常使用JS与以太坊的智能合约进行交互）的使用更加容易。

DApp浏览器的主要目的是：

1. 提供到一个以太坊节点的连接（或者连接到一个本地节点或者远程节点），和一个方便的切换不同节点（甚至是不同的网络）。
2. 提供一个帐户（或者一个钱包）来方便用户与DApp交互。

[Mist](https://github.com/ethereum/mist)是以太坊官方的DApp浏览器。一个漂亮的界面来与以太坊节点交互，与智能合约发、收交易。

[Status](https://status.im/)是一个手机上可以使用的DApp浏览器。

[MetaMask](https://metamask.io/)是一个Google浏览器扩展，把Chrome变成了一个DApp浏览器。它的核心特性是注入以太坊提供的js客户端库`web3`，到每一个界面，来让DApp连接到MetaMask提供的以太坊节点服务。不过这个Chrome扩展，可以允许你管理你的钱包，以及连接到不同的以太坊网络（译者注：包括本地的开发网络）。

[Parity](https://parity.io/parity.html)是一个以太坊客户端（也是一个全节点的实现），集成到了Web浏览器，并使之成为一个DApp浏览器。

## 以太坊节点

与比特币的节点类似。每个节点都存储了整个区块链的数据，并重放所有的交易以验证结果的状态。你可以通过[geth](https://github.com/ethereum/go-ethereum/wiki/geth)来运行一个全节点（官方的节点，go语言），或者[parity](https://github.com/paritytech/parity)来运行一个轻节点，它是第三方的，Rust语言写的。

你的节点需要知道从哪个区块链下载数据，以及与哪些节点交互，后面会说明一些常见的网络。

你也许可以运行下所有这些节点客户端。如果你不想自己运行一个这样的节点，有第三方的网关服务，比如[Infura](https://infura.io/)可以选择。另外还有专门用于测试和开发的，本地版本的节点，后面会提到。

如果你正在开发一个DApp的客户端，你并不总是需要主动提供连接到以太坊的节点。因为DApp的浏览器一般会提供对应的连接（译者注：话说这样，那使用这个，还得额外安装一个DApp浏览器呀）。

## 以太坊代币

现在你应该知道我们可以通过写智能合约，并将状态存到区块链上了？那如果，在状态这块，我们存的是一个Map类型，键是地址，值是整数。然后我们将这些整数值叫做余额，谁的余额呢？它就是我们要说的代币（译者注：代币的数据结构就是这样简单，存的就是某个用户，它当前的余额）。

是的，所有你刚才听到的代币，只是一些数据，存储在一个哈希表里，通过api或者所谓的协议，来进行增删改查。[这是一个简单的基本合约](https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/BasicToken.sol)。

你可以看看[ethereum的创建一个众筹合约的官方教程](https://www.ethereum.org/crowdsale)。你将会发现它仅仅是一个合约（Crowdsale）与另一个合约（MyToken）交互，和前面的基本合约类似。并没有什么神奇的地方。

人们使用代币来做各种各样的事情，阻拦大家如何使用的只有想像力。代币常常用来激励用户与某个协议进行交互，或者证明对某个资产的所有权，投票权等等。[Coinbase的Fred有一个很好的关于代币，为什么存在，如何使用的文章](https://www.youtube.com/watch?v=rktHO5R8Y9c)。

[Ethereum的创始人Vitalik最近有一个关于代币发售模型，也是一篇不错的文章](http://vitalik.ca/general/2017/06/09/sales.html)。

## ERC20代币与ERC23代币

每个人都开始定义自己与代币的交互协议，但这些很快显得陈旧，所以一些人开始集结起来，[创建了ERC20代币接口标准](https://github.com/ethereum/eips/issues/20)。大概意思是说，我们定义这些接口，这样大家可以相互统一调用，比如转帐定义为`transfer`，第一个参数为要转去的帐户地址`address _to`，第二个参数为要发送的ether的`uint _value`数量。

有些人觉得ERC20协议过于复杂了，所以他们提议了[ERC197](https://github.com/ethereum/EIPs/issues/179)，稍微简单一点。

由于在ERC20中存在的一个小问题，有人提议了一个新的[ERC23](https://github.com/ethereum/EIPs/issues/223)。ERC23是向后兼容ERC20的。如果你已经创建了一个代币合约，可以尝试来支持ERC23。

> 看起来ERC223和ERC23是相同的概念；ERC的值是223，但是当引用时，作者和所有的其它人误写成了ERC23非常多次，它现在也还是这样引用的。如果一句话说清楚的话，ERC223是规范号，代币说明时称为ERC23代币就好了。

## 协议代币与App币

协议代币为用来激励对某个协议的使用。比如，REP，Augur的声誉代币，用来鼓励对Augur去中心化预测协议的使用。大多数的以太坊的ERC20/ERC23代币都是协议代币，比如Golem的GNT，ICONOMI，BAT等等。

App币则是用来激励对某个特定DApp或客户端的使用，而不是因为其使用的协议提供的价值。其中一个例子是Status的SNT代币，可以用来在应用内获得价值（比如，进行消息推送，投票权，获得用户名等等）。

这种范式的转变是，我们可以开始投资协议代币而不是应用程序代币，因为我们可以建立在它们之上（任何人都可以在协议之上构建一个dapp，或为实现该协议的Dapp构建一个Dapp客户端）。

之前，这并不可能，因为加密代币，以及接下来的[协议创新的时代](http://continuations.com/post/148098927445/crypto-tokens-and-the-coming-age-of-protocol)，为了实现货币化，你自己可以在协议之上创建一个应用，并实现赢利。因为你自己可以实现协议的货币化，大家可以在未来更好的协作。

你也许可以阅读一下，关于0xProject的下面这篇[文章，关于这两者区别的详细说明](https://blog.0xproject.com/the-difference-between-app-coins-and-protocol-tokens-7281a428348c)。

## 与智能合约交互

你与智能合约的交互（也称做调用函数和读取状态）通过连接到某个以太坊节点，并执行操作码。当前有各种各样的以太坊客户端，可以方便进行开发。Geth和parity都提供了控制台或浏览器的方式来更好的与智能合约交互。

如果你想要一个程序的库用来与智能合约交互的接口，也有这样的客户端实现。对于JS语言，可以使用[web3.js](https://github.com/ethereum/web3.js/)。以于go语言，可以使用在[go-ethereum](https://github.com/ethereum/go-ethereum)中的`abigen`的程序，提供了go包，用来与智能合约交互。

如果只是用来测试和开发，可以使用[ethereumjs-testrpc](https://github.com/ethereumjs/testrpc)来运行一个本地节点（译者注：这个节点压短区块时间等，可以方便打整的开发与测试）。

当你部署了一个智能合约，你实际进行的操作是向地址`0x0`发送了一个交易，使用当前合约内容作为参数，[一个以太坊交易详解](https://medium.com/@codetractio/inside-an-ethereum-transaction-fa94ffca912f)。

## Truffle和Embark

一旦你开始写智能合约，你会重复做大量的操作，比如编译源码为字节码和abi，部署到网络，测试然后部署合约等等。你也许希望更关注于你想要实现的东西。

Truffle和Embark框架，标准化和自动化了这些琐碎的工作。它们提供了一个好的开发，部署，以及更为重要的，测试智能合约的体验。

你可以[查看这个文章](http://truffleframework.com/docs/getting_started)来开启使用Truffle的旅程。

[这篇文章，提供了使用Truffle来部署以及与智能合约交互的文章。](https://blog.zeppelin.solutions/the-hitchhikers-guide-to-smart-contracts-in-ethereum-848f08001f05)

[Embark](https://github.com/iurimatias/embark-framework)提供了类似的，帮助开发者组织工程的稍有些不同的工具。

当你一开始接触智能合约这块时，应该尽量不要使用框架。直到你明白了使用框架能带来的价值时，才应该开始使用，正如你不应该通过`rails new`来学习HTML语言一样。

## ETHPM

分享是关心，所以[ETHPM是一个去中心化的智能合约包管理资源库](https://www.ethpm.com/registry)。使用ETHPM，你可以关联或连接到某个著名的合约或库，减少代码重复，尽可能理想的为未来的开发提供好的基础。

[这里的这个规范](https://github.com/ethereum/EIPs/issues/190)，详细的说明了相关的信息以及背景。Truffle和Embark均可与之集成，并创造一个愉快的开发体验。

## 网络

Mainnet-以太坊主网，通常是所有客户端的默认网络。

[Ropsten](https://github.com/ethereum/ropsten) - 以太坊使用工作量证明的主测试网络。这个网络，因为低的计算量，容易遭到DDOS攻击，分片，或者其它问题。垃圾邮件攻击后被暂时放弃，最近才恢复使用。

[Kovan](https://github.com/kovan-testnet/proposal)-parity客户端组成的测试网络，使用授权证明来提升对垃圾邮件攻击的抗扰度，并且持续4秒的阻塞时间。

[Rinkeby](https://www.rinkeby.io/)-geth客户端组成的测试网络，使用集团共识，尽管计算量低，但是对恶意行为者更有弹性。

你可以自己搭建你自己的测试网络，也许使用[kubernetes](https://github.com/MaximilianMeister/kuberneteth)或者[docker-compose](https://capgemini.github.io/blockchain/ethereum-docker-compose/)，但也许你将很快就可以不需要花什么时间。

## 帐户与钱包

一个以太坊帐户就是一个私钥和公钥地址对。它们可以用来存储ether，创建时不需要花费gas。

钱包则是用来管理ether的智能合约（一些代码）。[这里是使用solidity写的一个钱包，运行于Mist浏览器](https://github.com/ethereum/meteor-dapp-wallet/blob/develop/Wallet.sol)。他们可以有许多的特性，比如多用户签名，纸？等等。

这样，我们就正确的定义了两个名词，前面看到其它人对这两个术语的困惑，并把所有能存ether的都叫作Wallet。

## EVM以及智能合约创建的状态

在每个全节点网络上运行的智能合约代码在EVM内执行。这是您的标准虚拟机，执行一些字节码，除了这个vm与网络，文件系统，进程等隔离。没有人想要编写字节码，所以我们有一些更高级别的语言编译为EVM字节码。

### Solidity

[Solidity](https://solidity.readthedocs.io/en/latest/)是第一批的描述智能合约的语言。当前是最流行的语言，因此也有最多的例子，文档，和教程。你应该学习这个，除非你有要学习其它的理由。

你可以使用基于浏览器的[Remix IDE](https://ethereum.github.io/browser-solidity/)来进行快速验证。

下面是一个Solidity的合约：

```text
pragma solidity ^0.4.11;
contract BasicToken {
mapping(address => uint256) balances;
function transfer(address _to, uint256 _value) returns () {
    balances[msg.sender] = balances[msg.sender] - _value;
    balances[_to] = balances[_to] + _value;
  }
function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }
}
```

## LLL

LLL，是一门Lisp风格的底层编程语言，就像语言名称看到的这样。虽然以太坊官方并没有将它作为主要需要支持的语言，但它仍旧持续进行着更新，且与[solidity在同一个资源库](https://github.com/ethereum/solidity)。

[这是一个使用LLL语言写的一个ERC20代币的合约](https://github.com/benjaminion/LLL_erc20/blob/1c659e890e2b30408555b9467a8dfd8988211b3b/erc20.lll)

LLL示例如下：

```text
(seq
  (def 'node-bytes  0x00)
  (def 'owner    0x20) ; address
  (def 'set-node-owner    0x5b0fc9c3) ; setOwner(bytes32,address)
  (def 'get-owner (node)
      (sload (+ node owner)))

//只是用来示例，不能编译通过
```

如果你正在学习，也许不是那么的容易习惯LLL语言的写法。

### Serpent

[Serpent](https://github.com/ethereum/serpent/tree/develop)是一个类Python的高级语言，最终也会被编译为EVM字节码。它主要被Augur团队使用。

但最近[Zeppelin Solution团队发现其编译器有一个严重的bug](https://blog.zeppelin.solutions/serpent-compiler-audit-3095d1257929)，在这个问题被修复之前都不建议继续使用。

如果你对Augur如何解决这些漏洞感兴趣，你可以阅读Zeppelin Solution的[这篇文章](https://blog.zeppelin.solutions/augur-rep-token-critical-vulnerability-disclosure-3d8bdffd79d2)。

Serpent的合约看起来如下：

```text
def register(key, value):
    # Key not yet claimed
    if not self.storage[key]:
        self.storage[key] = value
        return(1)
    else:
        return(0)  # Key already claimed

def ask(key):
    return(self.storage[key])
```

### 其它

在各种可用性和发展状态中还有一堆其他的高级语言，而且无疑将会被开发出来。 为了广泛采用，语言和编译器必须经过彻底的审查和测试，这当然需要时间。

### 智能合约反编译/Disassembly

可以通过[prosity](https://github.com/comaeio/porosity)来反编译以太坊智能合约的字节码，可以使用[evmdis](https://github.com/Arachnid/evmdis)来Disassembly。

## 智能合约的安全

一旦一个智能合约部署到了以太坊的网络上，它将是永不可变的，且将永久存在。如果你写了一个bug，你将不能下架这个有问题的版本，你只能在后续的版本中修复。

由于许多工程师开发的Ethereum和其他智能合同平台来自于Web开发，所以这个概念实在是太新，而且是疯狂的。

ConsenSys有一个[非常棒的资源叫智能合约的最佳实践](https://github.com/ConsenSys/smart-contract-best-practices)，你应该深入的理解一下。

[一个Parity的钱包被黑的解释](https://blog.zeppelin.solutions/on-the-parity-wallet-multisig-hack-405a8c12e8f7)。

在你部署你的智能合约的时候，由于你管理的是真正的资金，你应该先开一个[赏金计划](https://blog.zeppelin.solutions/setting-up-a-bug-bounty-smart-contract-with-openzeppelin-a0e56434ad0e)，并尽量保证它完整的测试过。

## Whisper

[Whisper](https://github.com/ethereum/go-ethereum/wiki/Whisper-Overview)是一个集成进以太坊的消息系统。它允许DApp发布小量的信息来进行非实时的消息通信。

它使用`shh`协议。

尽管它已经有段时间没有更新了，[这是一个使用Whisper协议实现一个聊天客户端的例子](https://github.com/ethereum/meteor-dapp-whisper-chat-client)。

## 去中心自动化组织（DAOs）

这是一个组织（就像，一群人），其中，使用代码来保证最终的强制执行，而不是使用传统的法律文件。这群人使用智能合约来做常见组织做的所有的事情，比如在某件事上进行投票，比如决定是否对什么进行投资等等。

副作用是决策，管理，以及对什么进行投资的结果将会不可改变的存储在区块链上。

之前slock.it创建了标准的DAO框架来说明这个理念。在[这里](https://github.com/slockit/DAO/)有对DAO概念的总览，以及如何使用框架来实现一个自己的DAO（译者注：这个项目由于bug被黑客攻击了）。

## Aragon

[Aragon](https://aragon.one/)也正在应对挑战，设计一个根据智能合约逻辑运作的公司，重点是创建一个可以接受投资，处理会计，支付雇员，分配股权，正如我们现在知道的完成每天的公司的业务。他们也实现了漂亮的DApp客户端来让他们的协议使用起来更为简单。

查看这里[Aragon核心合约](https://github.com/aragon/aragon-core/tree/master/contracts)来更多的理解它是如何做的。

## IPFS&FileCoin

[IPFS](https://ipfs.io/)（星际文件系统）是一个协议，用来分发文件。你可以认为它是一个基于`bittorrent`和`git`这样概念的一个文件系统，文件可以定位，且是不可变的。IPFS以[IPLD](http://ipld.io/)数据模型存储信息，它非常有趣，提供了一些特别的特性，你可以通过下面的说明了解一些。

这是一个新的协议，它有一个http的网关和文件系统适配器，这让你可以通过http，挂载整个互联网文件系统到你本地的盘`/ipfs`。IPFS还提供了一个寻址服务IPNS（星际命名空间），它允许可变的状态（需要注意的是在IPFS里的所有东西都是不可变的）。你甚至可以使用DNS TXT记录来定位到你的IPNS客户端，允许你生成用户友好的链接来指向到对应的数据。

[FileCoin](https://filecoin.io/)是Protocol Lab为创建一个去中心化的基于IPFS的存储市场的努力结果，也就是向整个网络提供存储资源的激励层。FileCoin的共识协议没有使用浪费资源的工作量证明，而是使用了`Proff of Replication`和`Proof of SpaceTime`来保证每片数据被复制某个特定的拷贝数量且存储某个特定的时间。

你应该读一下[IPFS的白皮书](https://github.com/ipfs/ipfs/blob/master/papers/ipfs-cap2pfs/ipfs-p2p-file-system.pdf)，[FileCoin的白皮书](https://filecoin.io/filecoin.pdf)，以及[IPLD的规范](https://github.com/ipld/specs/tree/master/ipld)。

由于当前FileCoin还没有上线，你可以使用当前的IPFS存储网络来运行html/css/js，并把作为一个类似[orbit-db](https://github.com/orbitdb/orbit-db)的数据库。

## Swarm

Swarm是一个去中心化的存储网络，集成于以太坊生态系统，作为第一阵营的项目，看看这里[关于IPFS与这个项目的比较和优劣](https://github.com/ethersphere/go-ethereum/wiki/IPFS-&-SWARM)。但本质上，基本上是一样的，除了它们有不同的哲学，并在底层使用稍微不同的协议。