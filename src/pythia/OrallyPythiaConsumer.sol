// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {IOrallyExecutorsRegistry} from "../registry/IOrallyExecutorsRegistry.sol";

contract OrallyPythiaConsumer {
    IOrallyExecutorsRegistry private registry;

    constructor(address _registry) {
        registry = IOrallyExecutorsRegistry(_registry);
    }

    function isExecutor(address _addr) public view returns (bool) {
        return registry.isPythiaExecutor(_addr);
    }

    modifier onlyExecutor() {
        if (!registry.isPythiaExecutor(msg.sender)) revert PythiaCallerUnauthorized(msg.sender);
        _;
    }

    error PythiaCallerUnauthorized(address caller);
}
