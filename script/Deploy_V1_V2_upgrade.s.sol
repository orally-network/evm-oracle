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
    address constant amaAddress;

    function run() public {
        console2.log("Running deploy script for the Factory contract");
        vm.startBroadcast();

        // redeploy executorsRegistry new multicall, new ApolloCoordinator
        OrallyExecutorsRegistry registry = new OrallyExecutorsRegistry();
        console2.log("OrallyExecutorsRegistry deployed at:", address(registry));

        OrallyMulticall multi = new OrallyMulticall(address(registry));
        console2.log("Multicall deployed at:", address(multi));

        ApolloCoordinatorV2 coordinator = new ApolloCoordinatorV2();
        console2.log("Coordinator deployed at:", address(coordinator));

        registry.initialize();
        registry.add(keccak256("PYTHIA_EXECUTOR"), pmaAddress);
        registry.add(keccak256("PYTHIA_EXECUTOR"), address(multi));

        registry.add(keccak256("APOLLO_EXECUTOR"), amaAddress);
        registry.add(keccak256("APOLLO_EXECUTOR"), address(multi));

        // re-deploy oracles
        OrallyPriceFeed btcOracle =
                    new OrallyPriceFeed(address(registry), 8, "BTC/USD");
        console2.log("BTC Oracle deployed at:", address(btcOracle));

        OrallyPriceFeed ethOracle =
                    new OrallyPriceFeed(address(registry), 18, "ETH/USD");
        console2.log("ETH Oracle deployed at:", address(ethOracle));

        OrallyPriceFeed usdtOracle =
                    new OrallyPriceFeed(address(registry), 6, "USDT/USD");
        console2.log("USDT Oracle deployed at:", address(usdtOracle));

        OrallyPriceFeed usdcOracle =
                    new OrallyPriceFeed(address(registry), 6, "USDC/USD");
        console2.log("USDC Oracle deployed at:", address(usdcOracle));

        OrallyPriceFeed bnbOracle =
                    new OrallyPriceFeed(address(registry), 8, "BNB/USD");
        console2.log("BNB Oracle deployed at:", address(bnbOracle));

        vm.stopBroadcast();
    }
}
