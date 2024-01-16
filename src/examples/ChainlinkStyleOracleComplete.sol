// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {OrallyPythiaConsumer} from "../consumers/OrallyPythiaConsumer.sol";

interface ChainlinkStyleInterface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function getRoundData(uint80 _roundId)
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

    event AnswerUpdated(string indexed pairId, int256 answer, uint256 rate, uint256 decimals, uint256 timestamp);
}

contract ChainlinkStyleOracleComplete is OrallyPythiaConsumer, ChainlinkStyleInterface {
    uint8 public decimals;
    string public description;
    uint256 public version;
    uint80 public currentRoundId;

    mapping(uint80 => Round) public rounds;

    struct Round {
        int256 answer;
        uint256 startedAt;
        uint256 updatedAt;
    }

    constructor(address _pythiaRegistry, uint8 _decimals, string memory _description, uint256 _version)
        OrallyPythiaConsumer(_pythiaRegistry)
    {
        decimals = _decimals;
        description = _description;
        version = _version;
    }

    function updateRate(string memory _pairId, uint256 _rate, uint256 _decimals, uint256 _timestamp)
        external
        onlyExecutor
    {
        int256 answer = int256((_rate * (10 ** uint256(decimals))) / (10 ** _decimals));
        rounds[currentRoundId].answer = answer;
        rounds[currentRoundId].startedAt = _timestamp;
        rounds[currentRoundId].updatedAt = block.timestamp;
        unchecked {
            currentRoundId++;
        }

        emit AnswerUpdated(_pairId, answer, _rate, _decimals, _timestamp);
    }

    function getRoundData(uint80 _roundId)
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return (_roundId, rounds[_roundId].answer, rounds[_roundId].startedAt, rounds[_roundId].updatedAt, _roundId);
    }

    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        uint80 round = currentRoundId - 1;
        return (round, rounds[round].answer, rounds[round].startedAt, rounds[round].updatedAt, round);
    }
}
