// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {PredictionGeneric} from "./PredictionGeneric.sol";

// temperature treats with decimals=1 (e.g. 25.5 = 255)
contract WeatherPrediction is PredictionGeneric {

    constructor(address _executorsRegistry) PredictionGeneric(_executorsRegistry) {
    }

    // for adapting data if needed
    function updateTemperature(string memory, uint256 _temperature, uint256 _decimals, uint256 _timestamp) public onlyExecutor {
        updateNumeric("weather", _temperature, _decimals, _timestamp);
    }
}
