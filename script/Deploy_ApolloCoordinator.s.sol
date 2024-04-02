// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

import {ApolloCoordinator} from "src/apollo/ApolloCoordinator.sol";

contract Deploy_ApolloCoordinator is Script {
    function run() public {
        console2.log("Running deploy script for the Factory contract");
        vm.startBroadcast();

        ApolloCoordinator apollo = new ApolloCoordinator();
        console2.log("ApolloCoordinator deployed at:", address(apollo));

        vm.stopBroadcast();
    }
}
