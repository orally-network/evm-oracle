// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.20;

import {OrallyPythiaConsumer} from "../consumers/OrallyPythiaConsumer.sol";

interface ChainlinkStyleInterface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function latestRoundData() external view returns (int256 answer, uint256 startedAt, uint256 updatedAt);
}

contract ChainlinkStyleOracleSimple is OrallyPythiaConsumer, ChainlinkStyleInterface {
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

    function updateRate(string memory _pairId, uint256 _rate, uint256 _decimals, uint256 _timestamp)
        external
        onlyExecutor
    {
        _pairId; // silence unused variable warning
        latestPrice = int256((_rate * (10 ** uint256(decimals))) / (10 ** _decimals));
        latestPriceTimestamp = _timestamp;
        latestUpdate = block.timestamp;
    }

    function latestRoundData() external view returns (int256 answer, uint256 startedAt, uint256 updatedAt) {
        return (latestPrice, latestPriceTimestamp, latestUpdate);
    }
}
