// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {OrallyPythiaConsumer} from "../consumers/OrallyPythiaConsumer.sol";

contract PythiaExecutionExample is OrallyPythiaConsumer {
    uint256 public value;

    constructor(address _executorsRegistry) OrallyPythiaConsumer(_executorsRegistry) {}

    function updateValue(uint256 _value) external onlyExecutor {
        value = _value;
    }
}
