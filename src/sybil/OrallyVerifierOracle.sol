// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {IOrallyVerifierOracle} from "./IOrallyVerifierOracle.sol";

/**
 * @title OrallyVerifierOracle
 * @notice Used to verify prices from Orally API
 */
contract OrallyVerifierOracle is Ownable, IOrallyVerifierOracle {
    using ECDSA for bytes32;

    struct PriceFeed {
        string pairId;
        uint256 price;
        uint256 decimals;
        uint256 timestamp;
    }

    mapping(address => bool) public reporters;

    mapping(string => PriceFeed) public priceFeeds;

    constructor(address owner) Ownable(owner) {}

    function verifyPacked(bytes32 _message, bytes memory _signature) public view returns (bool) {
        return reporters[ECDSA.recover(_message, _signature)];
    }

    function verifyUnpacked(
        string memory _pairId,
        uint256 _price,
        uint256 _decimals,
        uint256 _timestamp,
        bytes memory _signature
    ) public view returns (bool) {
        return verifyPacked(keccak256(abi.encodePacked(_pairId, _price, _decimals, _timestamp)), _signature);
    }

    function unpack(bytes32 _message) public pure returns (string memory, uint256, uint256, uint256) {
        return abi.decode(abi.encodePacked(_message), (string, uint256, uint256, uint256));
    }

    function verifyPriceFeed(bytes memory data) public view returns (string memory, uint256, uint256, uint256) {
        (string memory pairId, uint256 price, uint256 decimals, uint256 timestamp, bytes memory signature) = abi.decode(data, (string, uint256, uint256, uint256, bytes));

        require(verifyUnpacked(pairId, price, decimals, timestamp, signature), "Invalid signature");

        return (pairId, price, decimals, timestamp);
    }

    function verifyPriceFeedWithCache(bytes memory data) public returns (string memory, uint256, uint256, uint256) {
        (string memory pairId, uint256 price, uint256 decimals, uint256 timestamp) = verifyPriceFeed(data);

        priceFeeds[pairId] = PriceFeed(pairId, price, decimals, timestamp);

        return (pairId, price, decimals, timestamp);
    }

    function isReporter(address _reporter) external view returns (bool) {
        return reporters[_reporter];
    }

    function addReporter(address _reporter) external onlyOwner {
        reporters[_reporter] = true;
        emit ReporterAdded(_reporter);
    }

    function removeReporter(address _reporter) external onlyOwner {
        reporters[_reporter] = false;
        emit ReporterRemoved(_reporter);
    }
}
