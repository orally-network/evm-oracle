// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

import {WeatherAuction} from "src/examples/WeatherAuction.sol";

contract Deploy_1 is Script {
    address constant pythiaExecutorRegistry = 0x000000000000000000000000000000000000dEaD;

    function run() public {
        console2.log("Running deploy script for the Factory contract");
        vm.startBroadcast();

        WeatherAuction weatherAuction = new WeatherAuction(pythiaExecutorRegistry);
        console2.log("WeatherAuction deployed at:", address(weatherAuction));

        vm.stopBroadcast();
    }
}
