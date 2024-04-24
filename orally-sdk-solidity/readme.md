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

## Example Usage 1: Consuming Verifiable Price Feeds

To consume prices you should use the [`IOrallyVerifierOracle`](IOrallyVerifierOracle.sol) interface. Please make sure to read the documentation of this interface in order to use the prices safely.

For example, to read the latest price, call [`getPriceFeed`](IOrallyVerifierOracle.sol) with the feed ID of the price feed you're interested in. 

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@orally-network/solidity-sdk/IOrallyVerifierOracle.sol";

contract ExampleContract {
  IOrallyVerifierOracle oracle;

  constructor(address orallyVerifierOracleAddress) {
    oracle = IOrallyVerifierOracle(orallyVerifierOracleAddress);
  }

  // price data from
  // https://tysiw-qaaaa-aaaak-qcikq-cai.icp0.io/get_xrc_data_with_proof?id=DOGE/SHIB&bytes=true
  function getBtcUsdPrice(
    bytes calldata priceFeedData
  ) public payable returns (IOrallyVerifierOracle.PriceFeed memory) {
    // Verify the price feed data and get the price, decimals, and timestamp.
    (string memory pairId, uint256 price, uint256 decimals, uint256 timestamp) = oracle.verifyPriceFeed(priceFeedData);
    // if this price feed will be needed for later usage you can use `verifyPriceFeedWithCache` instead (+90k to gas) and access as `oracle.getPriceFeed("DOGE/SHIB")`

    return oracle.getPriceFeed("DOGE/SHIB");
  }
}

```