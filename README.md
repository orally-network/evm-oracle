# Orally EVM Oracles

Orally enables developers to consume price feeds through its Sybil service and API as well as automating actions through its Pythia service; both running on ICP and serving most EVM chains.

## Sybil integration

Developers can integrate Sybil in their contracts by inheriting from the `OrallySybilConsumer.sol` contract which can be found in the `contracts/consumers` directory.  
An example of this integration can be found at `contracts/examples/PriceConsumerExample.sol`.

In the constructor of the inheriting contract a Sybil address must be passed. This can be found in our documentation and might change depending on the blockchain you are using.

```cpp
constructor(address _oracle) OrallySybilConsumer(_oracle) {}
```

Functions that take Sybil arguments should verify the validity of the data by calling the `verifyPacked` or `verifyUnpacked` functions.

```js
function consumePacked(bytes32 _message, bytes memory _signature) public {
        require(
            verifyPacked(_message, _signature),
            "PriceConsumerExample: Invalid signature"
        );
        ...
    }
```

```js
function consumeUnpacked(
        string memory _pairId,
        uint256 _price,
        uint256 _decimals,
        uint256 _timestamp,
        bytes memory _signature
    ) public {
        require(
            verifyUnpacked(_pairId, _price, _decimals, _timestamp, _signature),
            "PriceConsumerExample: Invalid signature"
        );
        ...
    }
```

The verify functions will make sure that the data was signed by an Orally address. All orally addresses are stored in the `OrallyVerifierOracle` contract and can only be updated by the Orally team.

## Pythia integration

Pythia enables developers to automate calling functions on their contracts.

To start using Pythia, developers must inherit from the `OrallyPythiaConsumer.sol` contract which can be found in the `contracts/consumers` directory.

In the constructor of the inheriting contract a Pythia registry address must be passed. This can be found in our documentation and might change depending on the blockchain you are using. The Pythia registry stores addresses of all Pythia executors

```cpp
constructor(
        address _pythiaRegistry
    ) OrallyPythiaConsumer(_pythiaRegistry) {}
```

The function that should be called by Pythia must use the `onlyExecutor` modifier to make sure only allowed executors can call it.

Function arguments can either be `none` for simple automation, a single `uint256` argument for consuming randomness or `(string, uin256, uin256, uin256)` to consume price feeds.

Pythia subscriptions should be created through Orally's website.
