# Orally Solidity SDK

This package provides utilities for consuming 
- dynamic price/custom feeds
- automation services
- on-demand delivery of data

from the [Orally Network](https://orally.network) Oracle using Solidity. 

## Installation

###Truffle/Hardhat

If you are using Truffle or Hardhat, simply install the NPM package:

```bash
npm install @orally-network/solidity-sdk
```

###Foundry

If you are using Foundry, you will need to create an NPM project if you don't already have one.
From the root directory of your project, run:

```bash
npm init -y
npm install @orally-network/solidity-sdk
```

Then add the following line to your `remappings.txt` file:

```text
@orally-network/solidity-sdk/=node_modules/@orally-network/solidity-sdk
```

## Example 1: Consuming Verifiable Price Feeds

To consume prices you should use the [`IOrallyVerifierOracle`](IOrallyVerifierOracle.sol) interface. 

To verify price feed you should call the `verifyPriceFeedWithCache` function with `priceData` with a **proof** from HTTP Gateway: 

`https://tysiw-qaaaa-aaaak-qcikq-cai.icp0.io/get_xrc_data_with_proof?id=DOGE/SHIB&bytes=true`. 

You will get [`PriceFeed`](OrallyStructs.sol) struct as a return with the price, decimals, and timestamp.

Later to read the latest price, you can call [`getPriceFeed`](IOrallyVerifierOracle.sol) with the feed ID of the price feed you're interested in. 

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@orally-network/solidity-sdk/IOrallyVerifierOracle.sol";
import "@orally-network/solidity-sdk/OrallyStructs.sol";

contract ExampleContract {
    IOrallyVerifierOracle oracle;

    constructor(address orallyVerifierOracleAddress) {
        oracle = IOrallyVerifierOracle(orallyVerifierOracleAddress);
    }

    // price data from
    // https://tysiw-qaaaa-aaaak-qcikq-cai.icp0.io/get_xrc_data_with_proof?id=DOGE/SHIB&bytes=true
    function getDogeShibPrice(
        bytes calldata priceFeedData
    ) public payable returns (OrallyStructs.PriceFeed memory) {
        // Verify the price feed data and get the price, decimals, and timestamp.
        OrallyStructs.PriceFeed priceFeed = oracle.verifyPriceFeed(priceFeedData);
        // if this price feed will be needed for later usage you can use `verifyPriceFeedWithCache` instead (+90k to gas) and access as `oracle.getPriceFeed("DOGE/SHIB")`
        
        // priceFeed.price is the price of DOGE/SHIB
        // priceFeed.decimals is the number of decimals in the price
        // priceFeed.timestamp is the timestamp when price feed was aggregated

        return priceFeed;
    }
}
```
[More Details in Documentation](https://docs.orally.network/orally-products/sybil)

## Example 2: Consuming Verifiable Side Chain Data

To verify if address holding some token on the side chain. 

To consume side chain data you should use the [`IOrallyVerifierOracle`](IOrallyVerifierOracle.sol) interface.

To verify side chain data you should call the `verifyChainData` function with `chainData` with a **proof** from HTTP Gateway:

`https://tysiw-qaaaa-aaaak-qcikq-cai.icp0.io/read_contract_with_proof?chain_id=42161&function_signature="function balanceOf(address account) external view returns (uint256)"&contract_addr=0xA533f744B179F2431f5395978e391107DC76e103&method=balanceOf&params=(0x654DFF41D51c230FA400205A633101C5C1f1969C)&bytes=true`.

You will get `(bytes data, bytes metaData)` as a return. metaData could be decoded as [`OrallyStructs.ReadContractMetadata`](OrallyStructs.sol) and `data` depend on what you requested from side chain.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@orally-network/solidity-sdk/IOrallyVerifierOracle.sol";
import "@orally-network/solidity-sdk/OrallyStructs.sol";

contract ExampleContract {
    IOrallyVerifierOracle oracle;

    constructor(address orallyVerifierOracleAddress) {
        oracle = IOrallyVerifierOracle(orallyVerifierOracleAddress);
    }

    // chain data from
    // https://tysiw-qaaaa-aaaak-qcikq-cai.icp0.io/read_contract_with_proof?chain_id=42161&function_signature="function balanceOf(address account) external view returns (uint256)"&contract_addr=0xA533f744B179F2431f5395978e391107DC76e103&method=balanceOf&params=(0x654DFF41D51c230FA400205A633101C5C1f1969C)&bytes=true
    function getSideChainUserTokenBalance(
        bytes calldata chainData
    ) public payable returns (uint256) {
        // Verify the chain data and get the balance of the user.
        (bytes memory data, bytes memory metaData) = verifier.verifyChainData(chainData);

        (uint256 balance) = abi.decode(data, (uint256));
        (OrallyStructs.ReadContractMetadata memory meta) = abi.decode(metaData, (OrallyStructs.ReadContractMetadata));
        
        // balance is the balance of the user of the requested token
        // meta.chainId is the chain id of the side chain
        // meta.contractAddr is the address of the contract on the side chain
        // meta.method is the method that was called on the contract
        // meta.params is the parameters that were passed to the method

        return balance;
    }
}
```
[More Details in Documentation](https://docs.orally.network/orally-products/sybil)

## Example 3: Request and Handle Feeds From Your EVM Contract

To request feed from your contract you should use the [`IApolloCoordinator`](IApolloCoordinator.sol) interface.

You will receive requested data in `fulfillData` callback. You should utilize [`ApolloReceiver`](ApolloReceiver.sol) for that.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ApolloReceiver} from "@orally-network/solidity-sdk/ApolloReceiver.sol";

contract RequestingPriceFeedExample is ApolloReceiver {
    constructor(address _executorsRegistry, address _apolloCoordinator)
        ApolloReceiver(_executorsRegistry, _apolloCoordinator) {}

    // Example function to request a price feed
    // `apolloCoordinator` is passing as public var from ApolloReceiver contract
    function requestPriceFeed() public {
        // Requesting the ARB/UNI price feed with a specified callback gas limit
        uint256 requestId = apolloCoordinator.requestDataFeed("ARB/UNI", 100000);
    }

    // Overriding the fulfillData function to handle incoming data
    function fulfillData(bytes memory data) internal override {
        (
            uint256 _requestId,
            string memory _dataFeedId,
            uint256 _rate,
            uint256 _decimals,
            uint256 _timestamp
        ) = abi.decode(data, (
            uint256,
            string,
            uint256,
            uint256,
            uint256
        ));
        
        // ...
    }
}

contract RequestingRandomnessExample is ApolloReceiver {
    constructor(address _executorsRegistry, address _apolloCoordinator)
    ApolloReceiver(_executorsRegistry, _apolloCoordinator) {}

    // Example function to request a price feed
    // `apolloCoordinator` is passing as public var from ApolloReceiver contract
    function requestRandomness() public {
        // Requesting the randomness with a specified callback gas limit and number of random words
        apolloCoordinator.requestRandomFeed(300000, 1);
    }

    // Overriding the fulfillData function to handle incoming data
    function fulfillData(bytes memory data) internal override {
        (, uint256[] memory randomWords) = abi.decode(data, (uint256, uint256[]));

        // transform the result to a number between 1 and 100 inclusively
        uint256 randomNumber = (randomWords[0] % 100) + 1;

        // ...
    }
}
```

[More Details in Documentation](https://docs.orally.network/getting-started/apollo)

## Example 4: Handle Your Pythia Automation

To allow MPC wallet to make regular updates to your smart contract you should inherit from [`OrallyPythiaConsumer`](OrallyPythiaConsumer.sol).

You will utilize `onlyExecutor(workflowId)` modifier to allow only correct workflow from MPC wallet to update data in your contract.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {OrallyPythiaConsumer} from "@orally-network/solidity-sdk/OrallyPythiaConsumer.sol";

contract ExampleContract is OrallyPythiaConsumer {
    constructor(address _executorsRegistry)
        OrallyPythiaConsumer(_executorsRegistry, msg.sender) {}

    // Automation target method for receiving custom weather condition feed
    function updateTemperature(
        uint256 workflowId,
        string memory _feedId,
        uint256 _temperature,
        uint256 _decimals,
        uint256 _timestamp
    ) public onlyExecutor(workflowId) {
        // do something with that data
    }
    
    // ...
}
```

[More Details in Documentation](https://docs.orally.network/getting-started/pythia-automation)
