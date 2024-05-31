// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

import {OrallyVerifierOracle} from "../src/sybil/OrallyVerifierOracle.sol";
import {OrallyExecutorsRegistry} from "../src/registry/OrallyExecutorsRegistry.sol";
import {OrallyMulticall} from "../src/registry/OrallyMulticall.sol";
import {ApolloCoordinator} from "src/apollo/ApolloCoordinator.sol";
import {OrallyPriceFeed} from "../src/pythia/examples/OrallyPriceFeed.sol";

contract Deploy_1 is Script {
    address constant sybilAddress = 0x0000000000000000000000000000000000000000;

    // different between chains, could be added in different deployment script () on already deployed infrastructure
    address constant pmaAddress = 0x0000000000000000000000000000000000000000;

    // different between chains, could be added in different deployment script () on already deployed infrastructure
    address constant amaAddress = 0x0000000000000000000000000000000000000000;

    function run() public {
        console2.log("Running deploy script for the Factory contract");
        vm.startBroadcast();

        // deploy infrastructure

        OrallyVerifierOracle verifier = new OrallyVerifierOracle();
        verifier.initialize(msg.sender);
        console2.log("OrallyVerifierOracle deployed at:", address(verifier));

        OrallyExecutorsRegistry registry = new OrallyExecutorsRegistry();
        registry.initialize();
        console2.log("OrallyExecutorsRegistry deployed at:", address(registry));

        OrallyMulticall multi = new OrallyMulticall();
        multi.initialize(address(registry));
        console2.log("Multicall deployed at:", address(multi));

        ApolloCoordinator coordinator = new ApolloCoordinator();
        coordinator.initialize();
        console2.log("ApolloCoordinator deployed at:", address(coordinator));

        // Setup
        verifier.addReporter(sybilAddress);
        registry.add(keccak256("PYTHIA_EXECUTOR"), pmaAddress);
        registry.add(keccak256("PYTHIA_EXECUTOR"), address(multi));

        registry.add(keccak256("APOLLO_EXECUTOR"), amaAddress);
        registry.add(keccak256("APOLLO_EXECUTOR"), address(multi));


        // deploy oracles
        OrallyPriceFeed btcOracle =
                    new OrallyPriceFeed(address(registry), 8, "BTC/USD");
        console2.log("BTC Oracle deployed at:", address(btcOracle));

        OrallyPriceFeed ethOracle =
                    new OrallyPriceFeed(address(registry), 18, "ETH/USD");
        console2.log("ETH Oracle deployed at:", address(ethOracle));

//        OrallyPriceFeed usdtOracle =
//                    new OrallyPriceFeed(address(registry), 6, "USDT/USD");
//        console2.log("USDT Oracle deployed at:", address(usdtOracle));
//
//        OrallyPriceFeed usdcOracle =
//                    new OrallyPriceFeed(address(registry), 6, "USDC/USD");
//        console2.log("USDC Oracle deployed at:", address(usdcOracle));
//
//        OrallyPriceFeed bnbOracle =
//                    new OrallyPriceFeed(address(registry), 8, "BNB/USD");
//        console2.log("BNB Oracle deployed at:", address(bnbOracle));

        vm.stopBroadcast();
    }
}
