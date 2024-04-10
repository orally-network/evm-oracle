// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {IOrallyVerifierOracle} from "../sybil/IOrallyVerifierOracle.sol";

contract OrallySybilConsumer {
    IOrallyVerifierOracle public oracle;

    constructor(address _oracle) {
        oracle = IOrallyVerifierOracle(_oracle);
    }

    function verifyPacked(bytes32 _message, bytes memory _signature) public view returns (bool) {
        return oracle.verifyPacked(_message, _signature);
    }

    function verifyUnpacked(
        string memory _pairId,
        uint256 _price,
        uint256 _decimals,
        uint256 _timestamp,
        bytes memory _signature
    ) public view returns (bool) {
        return oracle.verifyUnpacked(_pairId, _price, _decimals, _timestamp, _signature);
    }

    function unpack(bytes32 _message) public view returns (string memory, uint256, uint256, uint256) {
        return oracle.unpack(_message);
    }

    modifier onlyReporter() {
        require(oracle.isReporter(msg.sender), "OrallySybilConsumer: Caller is not a reporter");
        _;
    }
}
