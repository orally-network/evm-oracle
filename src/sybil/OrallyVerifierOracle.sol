// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {IOrallyVerifierOracle} from "./IOrallyVerifierOracle.sol";

import {console2} from "@forge-std/console2.sol";

/**
 * @title OrallyVerifierOracle
 * @notice This contract is used to verify and cache data feeds from the Orally's Sybil canister.
 * It handles verification of signed data, unpacks and caches it for quick access.
 * The contract uses ECDSA for cryptographic operations and inherits from Ownable for access control.
 */
contract OrallyVerifierOracle is Ownable, IOrallyVerifierOracle {
    using ECDSA for bytes32;

    // Structure to store information about each price feed
    struct PriceFeed {
        string pairId;     // The identifier for the currency pair
        uint256 price;     // The latest price of the currency pair
        uint256 decimals;  // The decimal places for the price to ensure precision
        uint256 timestamp; // The timestamp when the price was last updated
    }

    // Mapping to track authorized reporters who can sign and submit price feeds (Sybil permissionless wallet)
    mapping(address => bool) public reporters;

    // Mapping to store the latest price feeds by pair ID
    mapping(string => PriceFeed) public priceFeeds;

    constructor(address owner) Ownable(owner) {}

    /**
     * @notice Verifies if a packed message signature is valid and from an authorized reporter.
     * @param _message The hash of the signed message.
     * @param _signature The digital signature of the message.
     * @return bool Returns true if the signature is valid and the signer is authorized.
     */
    function verifyPacked(bytes32 _message, bytes memory _signature) public view returns (bool) {
        return reporters[ECDSA.recover(_message, _signature)];
    }

    /**
     * @notice Verifies the unpacked data elements with their signature.
     * @param _pairId The currency pair identifier.
     * @param _price The price of the currency pair.
     * @param _decimals The number of decimals for the price.
     * @param _timestamp The timestamp of the price update.
     * @param _signature The digital signature covering the data.
     * @return bool Returns true if the signature is valid and the data is from an authorized reporter.
     */
    function verifyUnpacked(
        string memory _pairId,
        uint256 _price,
        uint256 _decimals,
        uint256 _timestamp,
        bytes memory _signature
    ) public view returns (bool) {
        return verifyPacked(keccak256(abi.encodePacked(_pairId, _price, _decimals, _timestamp)), _signature);
    }

    /**
     * @notice Extracts and returns price feed data from a packed message.
     * @param _message The packed message containing encoded price feed data.
     * @return Tuple containing the pair ID, price, decimals, and timestamp extracted from the message.
     */
    function unpack(bytes32 _message) external pure returns (string memory, uint256, uint256, uint256) {
        return abi.decode(abi.encodePacked(_message), (string, uint256, uint256, uint256));
    }

    /**
     * @notice Verifies the integrity and authenticity of price feed data, then returns it.
     * @param data The packed byte array containing the price feed and its signature.
     * @return Tuple of pair ID, price, decimals, and timestamp if the verification is successful.
     */
    function verifyPriceFeed(bytes memory data) public view returns (string memory, uint256, uint256, uint256) {
        (string memory pairId, uint256 price, uint256 decimals, uint256 timestamp, bytes memory signature) = abi.decode(data, (string, uint256, uint256, uint256, bytes));
        require(verifyUnpacked(pairId, price, decimals, timestamp, signature), "Invalid signature");
        return (pairId, price, decimals, timestamp);
    }

    /**
     * @notice Verifies, caches, and returns the details of a price feed.
     * Caching is performed to store the most recent and valid data.
     * @param data The packed data containing the price feed and its signature.
     * @return Tuple of pair ID, price, decimals, and timestamp.
     */
    function verifyPriceFeedWithCache(bytes memory data) external returns (string memory, uint256, uint256, uint256) {
        (string memory pairId, uint256 price, uint256 decimals, uint256 timestamp) = verifyPriceFeed(data);
        priceFeeds[pairId] = PriceFeed(pairId, price, decimals, timestamp);
        emit PriceFeedSaved(pairId, price, decimals, timestamp);
        return (pairId, price, decimals, timestamp);
    }

    /**
     * @notice Verifies and returns custom numerical data from provided packed data.
     * @param data The packed data containing custom numerical information and its signature.
     * @return Tuple containing the feed ID, numerical value, and decimals.
     */
    function verifyCustomNumber(bytes memory data) external view returns (string memory, uint256, uint256) {
        (string memory feedId, uint256 number, uint256 decimals, bytes memory signature) = abi.decode(data, (string, uint256, uint256, bytes));

        require(verifyPacked(keccak256(abi.encodePacked(feedId, number, decimals)), signature), "Invalid signature");

        return (feedId, number, decimals);
    }

    /**
     * @notice Verifies and returns custom string data from provided packed data.
     * @param data The packed data containing custom string information and its signature.
     * @return Tuple containing the feed ID and the string value.
     */
    function verifyCustomString(bytes memory data) external view returns (string memory, string memory) {
        (string memory feedId, string memory value, bytes memory signature) = abi.decode(data, (string, string, bytes));

        require(verifyPacked(keccak256(abi.encodePacked(feedId, value)), signature), "Invalid signature");

        return (feedId, value);
    }

    /**
     * @notice Checks if an address is an authorized reporter.
     * @param _reporter The address to check.
     */
    function isReporter(address _reporter) external view returns (bool) {
        return reporters[_reporter];
    }

    /**
     * @notice Adds a new reporter and authorizes them to submit signed data.
     * @param _reporter The address of the reporter to add.
     */
    function addReporter(address _reporter) external onlyOwner {
        reporters[_reporter] = true;
        emit ReporterAdded(_reporter);
    }

    /**
     * @notice Removes an authorized reporter.
     * @param _reporter The address of the reporter to remove.
     */
    function removeReporter(address _reporter) external onlyOwner {
        reporters[_reporter] = false;
        emit ReporterRemoved(_reporter);
    }
}
