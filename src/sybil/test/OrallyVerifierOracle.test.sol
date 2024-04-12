// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

import {OrallyVerifierOracle} from "../OrallyVerifierOracle.sol";

import {console2} from "@forge-std/console2.sol";


contract OrallyVerifierOracleTest is Test {
    address constant reporter = 0xBFD54D868BE89184f19f597489A9FA9385AA708e;

    uint256 fork;
    OrallyVerifierOracle verifier;

    function setUp() public {
//        fork = vm.createFork("https://mainnet.infura.io/v3/{key}");
//        vm.selectFork(fork);

        console2.log("msg.sender:", msg.sender);

        verifier = new OrallyVerifierOracle(msg.sender);

        verifier.addReporter(reporter);
    }

    function testAddReporter() public {
        verifier.addReporter(reporter);
        assertEq(verifier.isReporter(reporter), true);
    }

    function testRemoveReporter() public {
        verifier.removeReporter(reporter);
        assertEq(verifier.isReporter(reporter), false);
    }

    function testVerifyPriceFeed() public {
        (string memory pairId, uint256 price, uint256 decimals, uint256 timestamp) = verifier.verifyPriceFeed("0x00000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000bd3564e80000000000000000000000000000000000000000000000000000000000000009000000000000000000000000000000000000000000000000000000006617f89800000000000000000000000000000000000000000000000000000000000000e000000000000000000000000000000000000000000000000000000000000000085852502f444f47450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000");

        console2.log("pairId:", pairId);
        console2.log("price:", price);
        console2.log("decimals:", decimals);
        console2.log("timestamp:", timestamp);
    }

}
