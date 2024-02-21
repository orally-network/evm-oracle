// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {PredictionGeneric} from "./PredictionGeneric.sol";

// btc rate treats with decimals=0 (e.g. 52000.25 = 52000)
contract BitcoinPrediction is PredictionGeneric {

    constructor(address _executorsRegistry) PredictionGeneric(_executorsRegistry) {
    }

    // for adapting data if needed
    function updatePriceFeed(string _feedId, uint256 _btcRate, uint256 _decimals, uint256 _timestamp) public onlyExecutor {
        updateNumeric(_feedId, _btcRate / 10**_decimals, _decimals, _timestamp);
    }
}
