// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {OrallyPythiaConsumer} from "../pythia/OrallyPythiaConsumer.sol";

interface IFxPriceFeedExample {
    function pair() external view returns (string memory);

    function baseTokenAddr() external view returns (address);

    function decimalPlaces() external view returns (uint256);

    event AnswerUpdated(string indexed pairId, uint256 answer, uint256 rate, uint256 decimals, uint256 timestamp);
}

contract FxPriceFeedExample is OrallyPythiaConsumer, IFxPriceFeedExample {
    uint256 public rate;
    uint256 public lastUpdate;
    string public pair;
    address public baseTokenAddr;
    uint256 public decimalPlaces;

    constructor(address _executorsRegistry, string memory _pair, address _baseTokenAddr, uint256 _decimalPlaces)
        OrallyPythiaConsumer(_executorsRegistry)
    {
        pair = _pair;
        baseTokenAddr = _baseTokenAddr;
        decimalPlaces = _decimalPlaces;
    }

    function updateRate(string memory, uint256 _rate, uint256 _decimals, uint256 _timestamp) external onlyExecutor {
        rate = (_rate * (10 ** decimalPlaces)) / (10 ** _decimals); // normalise rate
        lastUpdate = _timestamp;

        emit AnswerUpdated(pair, rate, _rate, _decimals, _timestamp);
    }

    function updateTime() external view returns (uint256) {
        return lastUpdate;
    }

    function exchangeRate() external view returns (uint256) {
        return rate;
    }
}
