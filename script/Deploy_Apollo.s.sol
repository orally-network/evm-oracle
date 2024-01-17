// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

import {ApolloCoordinator} from "src/apollo/ApolloCoordinator.sol";
import {OrallyExecutorsRegistry} from "src/OrallyExecutorsRegistry.sol";

contract Deploy_Apollo is Script {
    address constant registry_address = 0x000000000000000000000000000000000000dEaD;

    function run() public {
        vm.startBroadcast();

        ApolloCoordinator coordinator = new ApolloCoordinator();
        console2.log("Coordinator deployed at:", address(coordinator));

        OrallyExecutorsRegistry registry = OrallyExecutorsRegistry(registry_address);
        registry.add(keccak256("APOLLO_EXECUTOR"), address(coordinator));

        vm.stopBroadcast();
    }
}
