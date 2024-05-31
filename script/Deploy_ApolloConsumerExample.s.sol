// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

import {ApolloConsumerExample} from "../src/apollo/examples/ApolloConsumerExample.sol";

contract Deploy_ApolloConsumerExample is Script {
    address constant pythiaExecutorRegistry = 0x0000000000000000000000000000000000000000;
    address constant apolloCoordinator = 0x0000000000000000000000000000000000000000;

    uint256 constant TICKET_PRICE = 10000000000000000;

    function run() public {
        console2.log("Running deploy script for the Factory contract");
        vm.startBroadcast();

        ApolloConsumerExample consumer = new ApolloConsumerExample(pythiaExecutorRegistry, apolloCoordinator);
        console2.log("ApolloConsumerExample deployed at:", address(consumer));

        vm.stopBroadcast();
    }
}
