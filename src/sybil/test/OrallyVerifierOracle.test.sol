// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

import {OrallyVerifierOracle} from "../OrallyVerifierOracle.sol";

import {console2} from "@forge-std/console2.sol";

contract OrallyVerifierOracleTest is Test {
    // random deployer address for testing
    address constant deployer = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;

    // Sybil permissionless wallet (staging)
    address constant stagingReporter = 0xBFD54D868BE89184f19f597489A9FA9385AA708e;

    /*
    source (staging): https://tysiw-qaaaa-aaaak-qcikq-cai.icp0.io/get_xrc_data_with_proof?id=DOGE/SHIB&bytes=true
    decoded data: {
      "data": {
        "DefaultPriceFeed": {
          "symbol": "DOGE/SHIB",
          "rate": 6767282465616,
          "decimals": 9,
          "timestamp": 1713285660
        }
      },
      "signature": "e11a43af066346343576d6e9c8a8945bdc9d76cf25c07f8e52624355480a648a49be00b980cd043bc994d47d6c1256b405d43e13610d51726de585786e0e41aa1c"
    }
    */
    bytes constant priceFeedData = hex"00000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000627a177ab50000000000000000000000000000000000000000000000000000000000000000900000000000000000000000000000000000000000000000000000000661eaa1c00000000000000000000000000000000000000000000000000000000000000e00000000000000000000000000000000000000000000000000000000000000009444f47452f5348494200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041e59c98fffd7aa182f5015f83dd9d11a30ece01f675efb7b4a491fc6e51c65fd2759c32ef9708b6262338d7027339ad3aa6a2819ad08be5dbd37898a5b5849beb1b00000000000000000000000000000000000000000000000000000000000000";

    /*
    source (staging): https://tysiw-qaaaa-aaaak-qcikq-cai.icp0.io/get_feed_data_with_proof?id=custom_BTC/USD_NUMBER&bytes=true
    decoded data: {
      "data": {
        "CustomNumber": {
          "id": "custom_BTC/USD_NUMBER",
          "value": 61854000000,
          "decimals": 6
        }
      },
      "signature": "49500f346ee88e09aa78c62cc0cf499ba9628521c14e750224335ec3bb4d96eb1029eb79c10e7fd2d0737c9da52fef43f404dc6447fcbf3b4d90b46d66649ed61b"
    }
    */
    bytes constant customNumberData = hex"00000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000e66c92380000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000015637573746f6d5f4254432f5553445f4e554d4245520000000000000000000000000000000000000000000000000000000000000000000000000000000000004149500f346ee88e09aa78c62cc0cf499ba9628521c14e750224335ec3bb4d96eb1029eb79c10e7fd2d0737c9da52fef43f404dc6447fcbf3b4d90b46d66649ed61b00000000000000000000000000000000000000000000000000000000000000";

    /*
    source (staging): https://tysiw-qaaaa-aaaak-qcikq-cai.icp0.io/get_asset_data_with_proof?id=custom_get_logs_example&bytes=true
    decoded data: {
      "data": {
        "CustomString": {
          "id": "custom_get_logs_example",
          "value": "ETH/USD"
        }
      },
      "signature": "b2df8f098a5ce1c9a9d89df1b6d7d46d3bdfafca60fa2b6f043759e6d7b9f75c67c2e251058fd86d2c88206ada8cf2289b361601304da7ff0053eb0782d496f91c"
    }
    */
    bytes constant customStringData = hex"000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000e00000000000000000000000000000000000000000000000000000000000000017637573746f6d5f6765745f6c6f67735f6578616d706c6500000000000000000000000000000000000000000000000000000000000000000000000000000000074554482f555344000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041b2df8f098a5ce1c9a9d89df1b6d7d46d3bdfafca60fa2b6f043759e6d7b9f75c67c2e251058fd86d2c88206ada8cf2289b361601304da7ff0053eb0782d496f91c00000000000000000000000000000000000000000000000000000000000000";

    uint256 fork;
    OrallyVerifierOracle verifier;
    uint256 reporterKey = 0xa11ce;
    address reporter;

    function setUp() public {
//        fork = vm.createFork("https://mainnet.infura.io/v3/{key}");
//        vm.selectFork(fork);

        reporter = vm.addr(reporterKey);

        console2.log("Reporter address: {}", reporter);

        vm.startPrank(deployer);
        verifier = new OrallyVerifierOracle(msg.sender);
        verifier.addReporter(reporter);
        verifier.addReporter(stagingReporter);
    }

    function testIsReporter() public {
        assertTrue(verifier.isReporter(reporter), "The reporter should be authorized.");
    }

    function testAddReporter() public {
        address newReporter = vm.addr(0x1234);
        verifier.addReporter(newReporter);
        assertTrue(verifier.isReporter(newReporter), "The reporter should be authorized.");
    }

    function testRemoveReporter() public {
        verifier.removeReporter(reporter);
        assertEq(verifier.isReporter(reporter), false);
    }

    function testVerifyPacked() public {
        // Simulating the creation of a valid signature
        bytes32 message = keccak256("Test message");
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(reporterKey, message); // Using Foundry's vm.sign to simulate reporter signing the message
        bytes memory signature = abi.encodePacked(r, s, v);

        assertTrue(verifier.verifyPacked(message, signature), "The signature should be valid.");
    }

    function testVerifyUnpacked() public {
        // Encoding data as expected by the verifyUnpacked function
        string memory pairId = "ETH/USD";
        uint256 price = 4000000000000000000000;
        uint256 decimals = 18;
        uint256 timestamp = block.timestamp;
        bytes32 dataHash = keccak256(abi.encodePacked(pairId, price, decimals, timestamp));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(reporterKey, dataHash); // Sign the hash of the data
        bytes memory signature = abi.encodePacked(r, s, v);

        assertTrue(verifier.verifyUnpacked(pairId, price, decimals, timestamp, signature), "The unpacked data should verify correctly.");
    }

    function testVerifyPriceFeed() public {
        (string memory pairId, uint256 price, uint256 decimals, uint256 timestamp) = verifier.verifyPriceFeed(priceFeedData);

        assertEq(pairId, "DOGE/SHIB");
        assertEq(price, 6767282465616);
        assertEq(decimals, 9);
        assertEq(timestamp, 1713285660);
    }

    function testVerifyPriceFeedWithCache() public {
        (string memory pairId, uint256 price, uint256 decimals, uint256 timestamp) = verifier.verifyPriceFeedWithCache(priceFeedData);

        assertEq(pairId, "DOGE/SHIB");
        assertEq(price, 6767282465616);
        assertEq(decimals, 9);
        assertEq(timestamp, 1713285660);
    }

    function testVerifyCustomNumber() public {
        (string memory id, uint256 value, uint256 decimals) = verifier.verifyCustomNumber(customNumberData);

        assertEq(id, "custom_BTC/USD_NUMBER");
        assertEq(value, 61854000000);
        assertEq(decimals, 6);
    }

    function testVerifyCustomString() public {
        (string memory id, string memory value) = verifier.verifyCustomString(customStringData);

        assertEq(id, "custom_get_logs_example");
        assertEq(value, "ETH/USD");
    }
}
