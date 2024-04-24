// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {OrallyStructs} from "../OrallyStructs.sol";

/**
 * @title IOrallyVerifierOracle
 * @notice Interface for the OrallyVerifierOracle contract.
 * This interface defines the required functions for verifying and handling
 * data feeds, specifically focusing on functionality related to price feeds
 * and custom data verification processes.
 */
interface IOrallyVerifierOracle {
    // Events to notify about changes in reporter status or data updates
    event ReporterAdded(address indexed reporter);
    event ReporterRemoved(address indexed reporter);
    event PriceFeedSaved(string indexed pairId, uint256 price, uint256 decimals, uint256 timestamp);

    /**
     * @notice Get the details of a specific price feed for cache.
     * @param pairId The identifier for the currency pair.
     */
    function getPriceFeed(string memory pairId) external view returns (OrallyStructs.PriceFeed memory);

    /**
     * @notice Verifies the authenticity of a packed message using a signature.
     * @param _message The hash of the message being verified.
     * @param _signature The digital signature associated with the message.
     * @return bool Returns true if the signature is valid and from a trusted source.
     */
    function verifyPacked(bytes32 _message, bytes memory _signature) external view returns (bool);

    /**
     * @notice Verifies the authenticity and integrity of unpacked data elements with their signature.
     * @param _pairId The identifier for the currency pair.
     * @param _price The latest reported price for the currency pair.
     * @param _decimals The number of decimal places for the reported price.
     * @param _timestamp The timestamp when the data was signed.
     * @param _signature The digital signature covering the data.
     * @return bool Returns true if the signature is valid and from an authorized source.
     */
    function verifyUnpacked(
        string memory _pairId,
        uint256 _price,
        uint256 _decimals,
        uint256 _timestamp,
        bytes memory _signature
    ) external view returns (bool);

    /**
     * @notice Unpacks a message containing price feed data.
     * @param _message The packed message containing encoded price feed data.
     * @return Tuple containing the pair ID, price, decimals, and timestamp extracted from the message.
     */
    function unpack(bytes32 _message) external pure returns (string memory, uint256, uint256, uint256);

    /**
     * @notice Checks if an address is an authorized reporter.
     * @param _reporter The address to check.
     * @return bool Returns true if the address is authorized to submit data.
     */
    function isReporter(address _reporter) external view returns (bool);

    /**
     * @notice Verifies and returns the details of a price feed from provided data.
     * @param data The packed data containing the price feed and its signature.
     * @return Tuple of pair ID, price, decimals, and timestamp if the verification is successful.
     */
    function verifyPriceFeed(bytes memory data) external view returns (OrallyStructs.PriceFeed memory);

    /**
     * @notice Verifies, caches, and returns the details of a price feed.
     * Caching is performed to store the most recent and valid data.
     * @param data The packed data containing the price feed and its signature.
     * @return Tuple of pair ID, price, decimals, and timestamp.
     */
    function verifyPriceFeedWithCache(bytes calldata data) external returns (OrallyStructs.PriceFeed memory);

    /**
     * @notice Verifies and returns custom numerical data from provided packed data.
     * @param data The packed data containing custom numerical information and its signature.
     * @return Tuple containing the feed ID, numerical value, and decimals.
     */
    function verifyCustomNumber(bytes calldata data) external returns (OrallyStructs.CustomNumber memory);

    /**
     * @notice Verifies and returns custom string data from provided packed data.
     * @param data The packed data containing custom string information and its signature.
     * @return Tuple containing the feed ID and the string value.
     */
    function verifyCustomString(bytes calldata data) external returns (OrallyStructs.CustomString memory);

    /**
     * @notice Verifies and returns the details of a chain data feed from provided data.
     * @param data The packed data containing the chain data feed and its signature.
     * @return Tuple of chainData and metaData if the verification is successful.
     */
    function verifyChainData(bytes calldata data) external returns (bytes memory, bytes memory);
}
