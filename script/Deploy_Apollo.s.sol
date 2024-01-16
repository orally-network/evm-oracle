// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

import {ApolloCoordinator} from "src/apollo/ApolloCoordinator.sol";

contract Deploy_Apollo is Script {
    function run() public {
        vm.startBroadcast();

        ApolloCoordinator coordinator = new ApolloCoordinator();
        console2.log("Coordinator deployed at:", address(coordinator));

        vm.stopBroadcast();
    }
}
