// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

import {OrallyVerifierOracle} from "../src/sybil/OrallyVerifierOracle.sol";
import {OrallyExecutorsRegistry} from "../src/registry/OrallyExecutorsRegistry.sol";
import {OrallyMulticall} from "../src/registry/OrallyMulticall.sol";
import {ApolloCoordinator} from "src/apollo/ApolloCoordinator.sol";
import {OrallyPriceFeed} from "../src/pythia/examples/OrallyPriceFeed.sol";

contract Deploy_Set_AMA is Script {
    address constant executorsRegistry = 0x0000000000000000000000000000000000000000;
    // different between chains, could be added in different deployment script () on already deployed infrastructure
    address constant amaAddress = 0x0000000000000000000000000000000000000000;

    function run() public {
        console2.log("Running deploy script for the Factory contract");
        vm.startBroadcast();

        // set ApolloMainAddress as executor
        OrallyExecutorsRegistry registry = OrallyExecutorsRegistry(executorsRegistry);

        registry.add(keccak256("APOLLO_EXECUTOR"), amaAddress);

        vm.stopBroadcast();
    }
}
