// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {OrallyPythiaConsumer} from "../OrallyPythiaConsumer.sol";

interface RoundedRandomnessInterface {
    function description() external view returns (string memory);

    function getRoundData(uint80 _roundId) external view returns (uint80 roundId, uint64 random);

    function latestRoundData() external view returns (uint80 roundId, uint64 random);

    event RandomUpdated(string indexed description, uint64 random, uint80 currentRoundId);
}

contract RoundedRandomness is OrallyPythiaConsumer, RoundedRandomnessInterface {
    string public description;
    uint80 public currentRoundId;

    mapping(uint80 => uint64) public rounds;

    constructor(address _executorsRegistry, string memory _description) OrallyPythiaConsumer(_executorsRegistry, msg.sender) {
        description = _description;
    }

    function updateRandom(uint256 workflowId, uint64 _random) external onlyExecutor(workflowId) {
        rounds[currentRoundId] = _random;
        unchecked {
            currentRoundId++;
        }

        emit RandomUpdated(description, _random, currentRoundId);
    }

    function getRoundData(uint80 _roundId) external view returns (uint80 roundId, uint64 random) {
        return (_roundId, rounds[_roundId]);
    }

    function latestRoundData() external view returns (uint80 roundId, uint64 random) {
        uint80 round = currentRoundId - 1;
        return (round, rounds[round]);
    }

    function getRandomNumber(uint80 _roundId, uint64 _maxRange) external view returns (uint64) {
        require(_maxRange > 0, "Max range should be greater than 0");
        require(_roundId < currentRoundId, "Round not complete");

        return (rounds[_roundId] % _maxRange) + 1;
    }
}
