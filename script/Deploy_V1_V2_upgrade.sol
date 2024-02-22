// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

import {OrallyVerifierOracle} from "src/OrallyVerifierOracle.sol";
import {OrallyExecutorsRegistry} from "src/OrallyExecutorsRegistry.sol";
import {OrallyMulticall} from "src/OrallyMulticall.sol";
import {ApolloCoordinatorV2} from "src/apollo/ApolloCoordinatorV2.sol";
import {OrallyPriceFeed} from "src/examples/OrallyPriceFeed.sol";

contract Deploy_V1_V2_upgrade is Script {
    address constant pmaAddress = 0x05C3F2A3Ae0b7f3775044EEFED8a864c47125F19;
    address constant sybilAddress = 0x60825063CB0f4EF508854Ad4913f3a6de86B3807;

    // different between chains
    address constant amaAddress = 0x000000000000000000000000000000000000dEaD;

    address constant registryAddress = 0x000000000000000000000000000000000000dEaD;

    function run() public {
        console2.log("Running deploy script for the Factory contract");
        vm.startBroadcast();

        // redeploy new multicall with new ApolloCoordinator

        OrallyMulticall multi = new OrallyMulticall(registryAddress);
        console2.log("Multicall deployed at:", address(multi));

        ApolloCoordinatorV2 coordinator = new ApolloCoordinatorV2();
        console2.log("Coordinator deployed at:", address(coordinator));

        OrallyExecutorsRegistry registry = OrallyExecutorsRegistry(registryAddress);

        // set concrete apollo address on chain and new multicall
        registry.add(keccak256("APOLLO_EXECUTOR"), amaAddress);
        registry.add(keccak256("APOLLO_EXECUTOR"), address(multi));

        vm.stopBroadcast();
    }
}
