// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {IOrallyVerifierOracle} from "./IOrallyVerifierOracleWithFee.sol";
import {OrallyStructs} from "../OrallyStructs.sol";

/**
 * @title OrallyVerifierOracle
 * @notice This contract is used to verify and cache data feeds from the Orally's Sybil canister.
 * It handles verification of signed data, unpacks and caches it for quick access.
 * The contract uses ECDSA for cryptographic operations and inherits from Ownable for access control.
 */
contract OrallyVerifierOracle is IOrallyVerifierOracle, OwnableUpgradeable {
    using ECDSA for bytes32;

    // Mapping to track authorized reporters who can sign and submit price feeds (Sybil permissionless wallet)
    mapping(address => bool) public reporters;

    // Mapping to store the latest price feeds by pair ID
    mapping(string => OrallyStructs.PriceFeed) public priceFeeds;
    // Mapping to store the latest custom number data by feed ID
    mapping(string => OrallyStructs.CustomNumber) public customNumbers;
    // Mapping to store the latest custom string data by feed ID
    mapping(string => OrallyStructs.CustomString) public customStrings;

    /**
     * @notice Initialises the upgradeable contract
     */
    function initialize(address owner) external virtual initializer {
        __Ownable_init(owner);
    }

    /**
     * @notice Gets the fee for updating a feed.
     * @param _data The packed data containing the feed and its metadata.
     * @return The fee for updating the feed.
     */
    function getUpdateFee(bytes memory _data) external pure returns (uint256) {
        (, bytes memory metaBytes,) = abi.decode(_data, (bytes, bytes, bytes));

        (OrallyStructs.Meta memory meta) = abi.decode(metaBytes, (OrallyStructs.Meta));

        return meta.fee;
    }

    // Price Feeds

    /**
     * @notice Gets the price feed data for a given pair ID.
     * @param _pairId The unique identifier for the currency pair.
     * @return The price feed data for the given pair ID.
     */
    function getPriceFeed(string memory _pairId) external view returns (OrallyStructs.PriceFeed memory) {
        return priceFeeds[_pairId];
    }

    /**
     * @notice Stores the price feed data in the contract's state.
     * @param _priceFeed The price feed data to store.
     * @return The stored price feed data.
     */
    function _storePriceFeed(OrallyStructs.PriceFeed memory _priceFeed) internal returns (OrallyStructs.PriceFeed memory) {
        priceFeeds[_priceFeed.pairId] = _priceFeed;
        emit PriceFeedSaved(_priceFeed.pairId, _priceFeed.price, _priceFeed.decimals, _priceFeed.timestamp);
        return _priceFeed;
    }

    /**
     * @notice Verifies the integrity and authenticity of price feed data, then returns it (if fee paid with API key / allowed domain).
     * @param _data The packed byte array containing the price feed and its signature.
     * @return Tuple of pair ID, price, decimals, and timestamp if the verification is successful.
     */
    function verifyPriceFeed(bytes memory _data) external view returns (OrallyStructs.PriceFeed memory) {
        (OrallyStructs.PriceFeed memory priceFeed) = abi.decode(_verifyGeneric(_data), (OrallyStructs.PriceFeed));

        return priceFeed;
    }

    /**
     * @notice Verifies, caches, and returns the details of a price feed (if fee paid with API key / allowed domain).
     * Caching is performed to store the most recent and valid data.
     * @param _data The packed data containing the price feed and its signature.
     * @return Tuple of pair ID, price, decimals, and timestamp.
     */
    function updatePriceFeed(bytes memory _data) external returns (OrallyStructs.PriceFeed memory) {
        return _storePriceFeed(
            abi.decode(
                _verifyGeneric(_data),
                (OrallyStructs.PriceFeed)
            )
        );
    }

    /**
     * @notice Verifies the integrity and authenticity of price feed data, then returns it (if fee paid in transaction).
     * @param _data The packed byte array containing the price feed and its signature.
     * @return Tuple of pair ID, price, decimals, and timestamp if the verification is successful.
     */
    function verifyPriceFeedWithFee(bytes memory _data) external payable returns (OrallyStructs.PriceFeed memory) {
        (OrallyStructs.PriceFeed memory priceFeed) = abi.decode(_verifyGenericWithFee(_data), (OrallyStructs.PriceFeed));

        return priceFeed;
    }

    /**
     * @notice Verifies, caches, and returns the details of a price feed (if fee paid in transaction).
     * Caching is performed to store the most recent and valid data.
     * @param _data The packed data containing the price feed and its signature.
     * @return Tuple of pair ID, price, decimals, and timestamp.
     */
    function updatePriceFeedWithFee(bytes memory _data) external payable returns (OrallyStructs.PriceFeed memory) {
        return _storePriceFeed(
            abi.decode(
                _verifyGenericWithFee(_data),
                (OrallyStructs.PriceFeed)
            )
        );
    }

    // --------------------------------------------------------------------------------------------------------
    // Custom Numbers

    /**
     * @notice Gets the custom number data for a given feed ID.
     * @param _feedId The unique identifier for the custom number feed.
     * @return The custom number data for the given feed ID.
     */
    function getCustomNumber(string memory _feedId) external view returns (OrallyStructs.CustomNumber memory) {
        return customNumbers[_feedId];
    }

    /**
     * @notice Stores the custom number data in the contract's state.
     * @param _customNumber The custom number data to store.
     * @return The stored custom number data.
     */
    function _storeCustomNumber(OrallyStructs.CustomNumber memory _customNumber) internal returns (OrallyStructs.CustomNumber memory) {
        customNumbers[_customNumber.feedId] = _customNumber;
        emit CustomNumberSaved(_customNumber.feedId, _customNumber.value, _customNumber.decimals);
        return _customNumber;
    }

    /**
     * @notice Verifies and returns custom numerical data from provided packed data.
     * @param data The packed data containing custom numerical information and its signature.
     * @return Tuple containing the feed ID, numerical value, and decimals.
     */
    function verifyCustomNumber(bytes memory data) external view returns (OrallyStructs.CustomNumber memory) {
        (OrallyStructs.CustomNumber memory customNumber) = abi.decode(_verifyGeneric(data), (OrallyStructs.CustomNumber));

        return customNumber;
    }

    /**
     * @notice Verifies, caches, and returns the details of a custom number feed (if fee paid with API key / allowed domain).
     * Caching is performed to store the most recent and valid data.
     * @param _data The packed data containing the custom number feed and its signature.
     * @return Tuple of feed ID, numerical value, and decimals.
     */
    function updateCustomNumber(bytes memory _data) external returns (OrallyStructs.CustomNumber memory) {
        return _storeCustomNumber(
            abi.decode(
                _verifyGeneric(_data),
                (OrallyStructs.CustomNumber)
            )
        );
    }

    /**
     * @notice Verifies the integrity and authenticity of custom number data, then returns it (if fee paid in transaction).
     * @param _data The packed byte array containing the custom number data and its signature.
     * @return Tuple of feed ID, numerical value, and decimals if the verification is successful.
     */
    function verifyCustomNumberWithFee(bytes memory _data) external payable returns (OrallyStructs.CustomNumber memory) {
        (OrallyStructs.CustomNumber memory customNumber) = abi.decode(_verifyGenericWithFee(_data), (OrallyStructs.CustomNumber));

        return customNumber;
    }

    /**
     * @notice Verifies, caches, and returns the details of a custom number feed (if fee paid in transaction).
     * Caching is performed to store the most recent and valid data.
     * @param _data The packed data containing the custom number feed and its signature.
     * @return Tuple of feed ID, numerical value, and decimals.
     */
    function updateCustomNumberWithFee(bytes memory _data) external payable returns (OrallyStructs.CustomNumber memory) {
        return _storeCustomNumber(
            abi.decode(
                _verifyGenericWithFee(_data),
                (OrallyStructs.CustomNumber)
            )
        );
    }

    // --------------------------------------------------------------------------------------------------------
    // Custom Strings

    /**
     * @notice Gets the custom string data for a given feed ID.
     * @param _feedId The unique identifier for the custom string feed.
     * @return The custom string data for the given feed ID.
     */
    function getCustomString(string memory _feedId) external view returns (OrallyStructs.CustomString memory) {
        return customStrings[_feedId];
    }

    /**
     * @notice Stores the custom string data in the contract's state.
     * @param _customString The custom string data to store.
     * @return The stored custom string data.
     */
    function _storeCustomString(OrallyStructs.CustomString memory _customString) internal returns (OrallyStructs.CustomString memory) {
        customStrings[_customString.feedId] = _customString;
        emit CustomStringSaved(_customString.feedId, _customString.value);
        return _customString;
    }

    /**
     * @notice Verifies and returns custom string data from provided packed data.
     * @param data The packed data containing custom string information and its signature.
     * @return Tuple containing the feed ID and the string value.
     */
    function verifyCustomString(bytes memory data) external view returns (OrallyStructs.CustomString memory) {
        (OrallyStructs.CustomString memory customString) = abi.decode(_verifyGeneric(data), (OrallyStructs.CustomString));

        return customString;
    }

    /**
     * @notice Verifies, caches, and returns the details of a custom string feed (if fee paid with API key / allowed domain).
     * Caching is performed to store the most recent and valid data.
     * @param _data The packed data containing the custom string feed and its signature.
     * @return Tuple of feed ID and the string value.
     */
    function updateCustomString(bytes memory _data) external returns (OrallyStructs.CustomString memory) {
        return _storeCustomString(
            abi.decode(
                _verifyGeneric(_data),
                (OrallyStructs.CustomString)
            )
        );
    }

    /**
     * @notice Verifies the integrity and authenticity of custom string data, then returns it (if fee paid in transaction).
     * @param _data The packed byte array containing the custom string data and its signature.
     * @return Tuple of feed ID and the string value if the verification is successful.
     */
    function verifyCustomStringWithFee(bytes memory _data) external payable returns (OrallyStructs.CustomString memory) {
        (OrallyStructs.CustomString memory customString) = abi.decode(_verifyGenericWithFee(_data), (OrallyStructs.CustomString));

        return customString;
    }

    /**
     * @notice Verifies, caches, and returns the details of a custom string feed (if fee paid in transaction).
     * Caching is performed to store the most recent and valid data.
     * @param _data The packed data containing the custom string feed and its signature.
     * @return Tuple of feed ID and the string value.
     */
    function updateCustomStringWithFee(bytes memory _data) external payable returns (OrallyStructs.CustomString memory) {
        return _storeCustomString(
            abi.decode(
                _verifyGenericWithFee(_data),
                (OrallyStructs.CustomString)
            )
        );
    }

    // --------------------------------------------------------------------------------------------------------
    // Chain Data

    /**
     * @notice Verifies and returns the details of a chain data feed from provided feed.
     * @param _chainData The packed data containing the chain data feed and its signature.
     * @return Tuple of chainData and metaData if the verification is successful.
     */
    function verifyReadContractData(bytes memory _chainData) external view returns (bytes memory, bytes memory) {
        (bytes memory dataBytes, bytes memory metaBytes, bytes memory signature) = abi.decode(_chainData, (bytes, bytes, bytes));
        (OrallyStructs.ReadContractMetadata memory meta) = abi.decode(metaBytes, (OrallyStructs.ReadContractMetadata));

        require(meta.fee == 0, "InvalidFee");

        bytes memory signedMessage = abi.encodePacked(dataBytes, metaBytes);

        require(_verifyPacked(keccak256(signedMessage), signature), "InvalidSignature");

        return (dataBytes, metaBytes);
    }

    /**
     * @notice Verifies and returns the details of a chain data feed from provided feed.
     * @param _chainData The packed data containing the chain data feed and its signature.
     * @return Tuple of chainData and metaData if the verification is successful.
     */
    function verifyReadLogsData(bytes memory _chainData) external view returns (bytes memory, bytes memory) {
        (bytes memory dataBytes, bytes memory metaBytes, bytes memory signature) = abi.decode(_chainData, (bytes, bytes, bytes));
        (OrallyStructs.ReadLogsMetadata memory meta) = abi.decode(metaBytes, (OrallyStructs.ReadLogsMetadata));

        require(meta.fee == 0, "InvalidFee");

        bytes memory signedMessage = abi.encodePacked(dataBytes, metaBytes);

        require(_verifyPacked(keccak256(signedMessage), signature), "InvalidSignature");

        return (dataBytes, metaBytes);
    }

    /**
     * @notice Verifies and returns the details of a chain data feed from provided feed.
     * @param _chainData The packed data containing the chain data feed and its signature.
     * @return Tuple of chainData and metaData if the verification is successful.
     */
    function verifyReadContractDataWithFee(bytes memory _chainData) external payable returns (bytes memory, bytes memory) {
        (bytes memory dataBytes, bytes memory metaBytes, bytes memory signature) = abi.decode(_chainData, (bytes, bytes, bytes));
        (OrallyStructs.ReadContractMetadata memory meta) = abi.decode(metaBytes, (OrallyStructs.ReadContractMetadata));

        require(msg.value >= meta.fee, "InsufficientFee");

        bytes memory signedMessage = abi.encodePacked(dataBytes, metaBytes);

        require(_verifyPacked(keccak256(signedMessage), signature), "InvalidSignature");

        return (dataBytes, metaBytes);
    }

    /**
     * @notice Verifies and returns the details of a chain data feed from provided feed.
     * @param _chainData The packed data containing the chain data feed and its signature.
     * @return Tuple of chainData and metaData if the verification is successful.
     */
    function verifyReadLogsDataWithFee(bytes memory _chainData) external payable returns (bytes memory, bytes memory) {
        (bytes memory dataBytes, bytes memory metaBytes, bytes memory signature) = abi.decode(_chainData, (bytes, bytes, bytes));
        (OrallyStructs.ReadLogsMetadata memory meta) = abi.decode(metaBytes, (OrallyStructs.ReadLogsMetadata));

        require(msg.value >= meta.fee, "InsufficientFee");

        bytes memory signedMessage = abi.encodePacked(dataBytes, metaBytes);

        require(_verifyPacked(keccak256(signedMessage), signature), "InvalidSignature");

        return (dataBytes, metaBytes);
    }

    // --------------------------------------------------------------------------------------------------------
    // Verifiers

    /**
     * @notice Verifies if a packed message signature is valid and from an authorized reporter.
     * @param _message The hash of the signed message.
     * @param _signature The digital signature of the message.
     * @return bool Returns true if the signature is valid and the signer is authorized.
     */
    function _verifyPacked(bytes32 _message, bytes memory _signature) internal view returns (bool) {
        return reporters[ECDSA.recover(_message, _signature)];
    }

    /**
     * @notice Verifies if a packed message signature is valid, from an authorized reporter.
     * @param _genericBytes The packed data containing the feed and its metadata.
     * @param _metaBytes The packed metadata containing the feed ID and timestamp.
     * @param _signature The digital signature of the message.
     * @return bytes Returns the verified data if the signature is valid and the signer is authorized.
     */
    function _verify(bytes memory _genericBytes, bytes memory _metaBytes, bytes memory _signature) internal view returns (bytes memory) {
        bytes memory signedMessage = abi.encodePacked(_genericBytes, _metaBytes);

        require(_verifyPacked(keccak256(signedMessage), _signature), "InvalidSignature");

        return _genericBytes;
    }

    /**
     * @notice Verifies if a packed message signature is valid, from an authorized reporter.
     * @param _data The packed data containing the feed and its metadata.
     * @return bytes Returns the verified data if the signature is valid and the signer is authorized.
     */
    function _verifyGeneric(bytes memory _data) internal view returns (bytes memory) {
        (bytes memory genericBytes, bytes memory metaBytes, bytes memory signature) = abi.decode(_data, (bytes, bytes, bytes));
        (OrallyStructs.Meta memory meta) = abi.decode(metaBytes, (OrallyStructs.Meta));

        require(meta.fee == 0, "InvalidFee");

        return _verify(genericBytes, metaBytes, signature);
    }

    /**
     * @notice Verifies if a packed message signature is valid, from an authorized reporter, and correct fee attached.
     * @param _data The packed data containing the feed and its metadata.
     * @return bytes Returns the verified data if the signature is valid, the signer is authorized and correct fee attached.
     */
    function _verifyGenericWithFee(bytes memory _data) internal returns (bytes memory) {
        (bytes memory genericBytes, bytes memory metaBytes, bytes memory signature) = abi.decode(_data, (bytes, bytes, bytes));
        (OrallyStructs.Meta memory meta) = abi.decode(metaBytes, (OrallyStructs.Meta));

        require(msg.value >= meta.fee, "InsufficientFee");

        return _verify(genericBytes, metaBytes, signature);
    }

    // --------------------------------------------------------------------------------------------------------
    // Reporters

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
