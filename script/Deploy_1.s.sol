// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

import {OrallyVerifierOracle} from "src/OrallyVerifierOracle.sol";
import {OrallyPythiaExecutorsRegistry} from "src/OrallyPythiaExecutorsRegistry.sol";
import {Multicall} from "src/Multicall.sol";

contract Deploy_1 is Script {
    address constant deadAddress = 0x000000000000000000000000000000000000dEaD;
    address constant pmaAddress = 0x05C3F2A3Ae0b7f3775044EEFED8a864c47125F19;
    address constant sybilAddress = 0x60825063CB0f4EF508854Ad4913f3a6de86B3807;

    function run() public {
        console2.log("Running deploy script for the Factory contract");
        vm.startBroadcast();

        OrallyVerifierOracle verifier = new OrallyVerifierOracle(msg.sender);
        console2.log("OrallyVerifierOracle deployed at:", address(verifier));

        OrallyPythiaExecutorsRegistry registry = new OrallyPythiaExecutorsRegistry();
        console2.log("OrallyPythiaExecutorsRegistry deployed at:", address(registry));

        Multicall multi = new Multicall(address(registry));
        console2.log("Multicall deployed at:", address(multi));

        // Setup
        verifier.addReporter(sybilAddress);
        registry.initialize();
        registry.add(pmaAddress);
        registry.add(address(multi));

        vm.stopBroadcast();
    }
}
