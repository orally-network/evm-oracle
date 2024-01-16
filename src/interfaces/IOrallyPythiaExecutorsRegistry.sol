// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

interface IOrallyPythiaExecutorsRegistry {
    function isExecutor(address _addr) external view returns (bool);

    event ExecutorAdded(address indexed executor);

    event ExecutorRemoved(address indexed executor);
}
