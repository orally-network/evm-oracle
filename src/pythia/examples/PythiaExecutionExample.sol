// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {OrallyPythiaConsumer} from "../OrallyPythiaConsumer.sol";

contract PythiaExecutionExample is OrallyPythiaConsumer {
    uint256 public value;

    constructor(address _executorsRegistry) OrallyPythiaConsumer(_executorsRegistry, msg.sender) {}

    function updateValue(uint256 workflowId, uint256 _value) external onlyExecutor(workflowId) {
        value = _value;
    }
}
