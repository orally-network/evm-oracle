// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {IOrallyExecutorsRegistry} from "../registry/IOrallyExecutorsRegistry.sol";

contract OrallyPythiaConsumer is Ownable {
    IOrallyExecutorsRegistry private registry;

    uint256 workflowId = 0;

    constructor(address _registry, address _owner) Ownable(_owner) {
        registry = IOrallyExecutorsRegistry(_registry);
    }

    function isExecutor(address _addr) public view returns (bool) {
        return registry.isPythiaExecutor(_addr);
    }

    function setWorkflowId(uint256 _workflowId) public onlyExecutor(0) {
        require(workflowId == 0, "Workflow ID already set");

        workflowId = _workflowId;
    }

    function resetWorkflowId() public onlyOwner {
        workflowId = 0;
    }

    function setWorkflowIdForce(uint256 _workflowId) public onlyOwner {
        workflowId = _workflowId;
    }

    modifier onlyExecutor(uint256 _workflowId) {
        if (!registry.isPythiaExecutor(msg.sender) || workflowId != _workflowId) revert PythiaCallerUnauthorized(msg.sender);
        _;
    }

    error PythiaCallerUnauthorized(address caller);
}
