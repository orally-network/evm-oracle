// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {PredictionGeneric} from "./PredictionGeneric.sol";

// for btc and eth
// btc rate treats with decimals=0 (e.g. 52000.25 = 52000)
contract PriceFeedPrediction is PredictionGeneric {

    constructor(address _executorsRegistry, string memory _description) PredictionGeneric(_executorsRegistry, _description) {
    }

    // for adapting data if needed
    function updatePriceFeed(uint256 workflowId, string memory _feedId, uint256 _btcRate, uint256 _decimals, uint256 _timestamp) public onlyExecutor(workflowId) {
        updateNumeric(_feedId, _btcRate / 10**_decimals, _decimals, _timestamp);
    }
}
