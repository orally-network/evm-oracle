// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {IOrallyPythiaExecutorsRegistry} from "./interfaces/IOrallyPythiaExecutorsRegistry.sol";

/**
 * @title OrallyPythiaExecutorsRegistry
 * @notice Used to store all executor addresses
 */
contract OrallyPythiaExecutorsRegistry is OwnableUpgradeable, IOrallyPythiaExecutorsRegistry {
    mapping(address => bool) public executors;

    /**
     * @notice Initialises the upgradeable contract
     */
    function initialize() external virtual initializer {
        __Ownable_init(msg.sender);
    }

    function isExecutor(address _addr) public view returns (bool) {
        return executors[_addr];
    }

    function add(address _addr) public onlyOwner {
        require(!executors[_addr], "Executor already exists");
        executors[_addr] = true;
        emit ExecutorAdded(_addr);
    }

    function remove(address _addr) public onlyOwner {
        require(executors[_addr], "Executor does not exist");
        executors[_addr] = false;
        emit ExecutorRemoved(_addr);
    }
}
