// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

import {ChainlinkStyleOracleSimple} from "src/examples/ChainlinkStyleOracleSimple.sol";

contract Deploy_2 is Script {
    address constant orallyPythiaExecutorsRegistryAddress = 0x000000000000000000000000000000000000dEaD;

    function run() public {
        console2.log("Running deploy script for the Factory contract");
        vm.startBroadcast();

        ChainlinkStyleOracleSimple btcOracle =
            new ChainlinkStyleOracleSimple(orallyPythiaExecutorsRegistryAddress, 8, "BTC/USD");
        console2.log("BTC Oracle deployed at:", address(btcOracle));

        ChainlinkStyleOracleSimple ethOracle =
            new ChainlinkStyleOracleSimple(orallyPythiaExecutorsRegistryAddress, 18, "ETH/USD");
        console2.log("ETH Oracle deployed at:", address(ethOracle));

        ChainlinkStyleOracleSimple usdcOracle =
            new ChainlinkStyleOracleSimple(orallyPythiaExecutorsRegistryAddress, 6, "USDC/USD");
        console2.log("USDC Oracle deployed at:", address(usdcOracle));

        ChainlinkStyleOracleSimple usdtOracle =
            new ChainlinkStyleOracleSimple(orallyPythiaExecutorsRegistryAddress, 6, "USDT/USD");
        console2.log("USDT Oracle deployed at:", address(usdtOracle));

        ChainlinkStyleOracleSimple bnbOracle =
            new ChainlinkStyleOracleSimple(orallyPythiaExecutorsRegistryAddress, 8, "BNB/USD");
        console2.log("BNB Oracle deployed at:", address(bnbOracle));

        vm.stopBroadcast();
    }
}
