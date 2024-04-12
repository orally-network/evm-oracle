// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

interface IOrallyVerifierOracle {
    function verifyPacked(bytes32 _message, bytes calldata _signature) external view returns (bool);

    function verifyUnpacked(
        string calldata _pairId,
        uint256 _price,
        uint256 _decimals,
        uint256 _timestamp,
        bytes calldata _signature
    ) external view returns (bool);

    function unpack(bytes32 _message) external pure returns (string memory, uint256, uint256, uint256);

    function isReporter(address _reporter) external view returns (bool);

    event ReporterAdded(address indexed reporter);

    event ReporterRemoved(address indexed reporter);
}
