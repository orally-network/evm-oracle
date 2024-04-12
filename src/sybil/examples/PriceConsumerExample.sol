// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {OrallySybilConsumer} from "../OrallySybilConsumer.sol";

contract PriceConsumerExample is OrallySybilConsumer {
    uint256 public price;
    uint256 public decimals;
    uint256 public timestamp;

    constructor(address _oracle) OrallySybilConsumer(_oracle) {}

    function updatePacked(bytes32 _message, bytes calldata _signature) public {
        require(verifyPacked(_message, _signature), "PriceConsumerExample: Invalid signature");
        (, uint256 _price, uint256 _decimals, uint256 _timestamp) = unpack(_message);
        price = _price;
        decimals = _decimals;
        timestamp = _timestamp;
    }

    function updateUnpacked(
        string calldata _pairId,
        uint256 _price,
        uint256 _decimals,
        uint256 _timestamp,
        bytes calldata _signature
    ) public {
        require(
            verifyUnpacked(_pairId, _price, _decimals, _timestamp, _signature),
            "PriceConsumerExample: Invalid signature"
        );
        price = _price;
        decimals = _decimals;
    }
}
