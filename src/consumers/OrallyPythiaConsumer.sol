// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {IOrallyPythiaExecutorsRegistry} from "../interfaces/IOrallyPythiaExecutorsRegistry.sol";

contract OrallyPythiaConsumer {
    IOrallyPythiaExecutorsRegistry public registry;

    constructor(address _registry) {
        registry = IOrallyPythiaExecutorsRegistry(_registry);
    }

    function isExecutor(address _addr) public view returns (bool) {
        return registry.isExecutor(_addr);
    }

    modifier onlyExecutor() {
        require(registry.isExecutor(msg.sender), "OrallyPythiaConsumer: Caller is not an executor");
        _;
    }
}
