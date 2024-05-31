// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

import {RaffleExample} from "../src/apollo/examples/RaffleExample.sol";

contract Deploy_RaffleExample is Script {
    address constant pythiaExecutorRegistry = 0x0000000000000000000000000000000000000000;
    address constant apolloCoordinator = 0x0000000000000000000000000000000000000000;

    uint256 constant TICKET_PRICE = 10000000000000000;

    function run() public {
        console2.log("Running deploy script for the Factory contract");
        vm.startBroadcast();

        RaffleExample raffle = new RaffleExample(pythiaExecutorRegistry, apolloCoordinator, 100, TICKET_PRICE);
        console2.log("RaffleExample deployed at:", address(raffle));

        vm.stopBroadcast();
    }
}
