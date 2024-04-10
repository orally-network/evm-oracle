// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {OrallyPythiaConsumer} from "../pythia/OrallyPythiaConsumer.sol";

interface ChainlinkStyleInterface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function latestRoundData() external view returns (int256 answer, uint256 startedAt, uint256 updatedAt);

    event AnswerUpdated(string indexed pairId, int256 answer, uint256 rate, uint256 decimals, uint256 timestamp);
}

contract OrallyPriceFeed is OrallyPythiaConsumer, ChainlinkStyleInterface {
    uint8 public decimals;
    string public description;
    uint256 public latestUpdate;
    uint256 public latestPriceTimestamp;
    int256 public latestPrice;

    constructor(address _executorsRegistry, uint8 _decimals, string memory _description)
        OrallyPythiaConsumer(_executorsRegistry)
    {
        decimals = _decimals;
        description = _description;
    }

    function updateRate(string memory, uint256 _rate, uint256 _decimals, uint256 _timestamp) external onlyExecutor {
        latestPrice = int256((_rate * (10 ** uint256(decimals))) / (10 ** _decimals));
        latestPriceTimestamp = _timestamp;
        latestUpdate = block.timestamp;

        emit AnswerUpdated(description, latestPrice, _rate, _decimals, _timestamp);
    }

    function latestRoundData() external view returns (int256 answer, uint256 startedAt, uint256 updatedAt) {
        return (latestPrice, latestPriceTimestamp, latestUpdate);
    }
}
