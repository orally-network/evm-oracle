// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

import {OrallyVerifierOracle} from "src/sybil/OrallyVerifierOracle.sol";

contract Deploy_OrallyVerifier is Script {
    address constant reporter = 0xBFD54D868BE89184f19f597489A9FA9385AA708e;

    function run() public {
        console2.log("Running deploy script for the Factory contract");
        vm.startBroadcast();

        OrallyVerifierOracle verifier = new OrallyVerifierOracle(msg.sender);
        console2.log("OrallyVerifierOracle deployed at:", address(verifier));

        verifier.addReporter(reporter);

        vm.stopBroadcast();
    }
}
