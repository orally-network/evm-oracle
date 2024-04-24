// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

contract OrallyStructs {
    // Structure to store information about each price feed
    struct PriceFeed {
        string pairId;     // The identifier for the currency pair
        uint256 price;     // The latest price of the currency pair
        uint256 decimals;  // The decimal places for the price to ensure precision
        uint256 timestamp; // The timestamp when the price was last updated
    }

    // Structure to store custom number data
    struct CustomNumber {
        string feedId;      // The identifier for the data feed
        uint256 value;      // The custom number value
        uint256 decimals;   // The timestamp when the number was last updated
    }

    // Structure to store custom string data
    struct CustomString {
        string feedId;  // The identifier for the data feed
        string value;   // The custom string data
    }

    // Structure to store chain data feed and metadata
    struct ReadContractMetadata {
        uint256 chain_id;
        address contract_address;
        string method;
        string params;
        uint256 timestamp;
    }
}
