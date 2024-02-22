// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

import {WeatherPrediction} from "src/prediction/WeatherPrediction.sol";
import {PriceFeedPrediction} from "src/prediction/PriceFeedPrediction.sol";
import {RandomPrediction} from "src/prediction/RandomPrediction.sol";

contract Deploy_PredictionSet is Script {
    address constant executorsRegistry = 0x000000000000000000000000000000000000dEaD;

    function run() public {
        console2.log("Running deploy script for the Factory contract");
        vm.startBroadcast();

        WeatherPrediction weatherPredictionL = new WeatherPrediction(executorsRegistry, "WeatherPrediction: Temperature in Celsius: 0.1 precision: Lisbon");
        console2.log("WeatherPrediction(Lisbon) deployed at:", address(weatherPredictionL));

        WeatherPrediction weatherPredictionD = new WeatherPrediction(executorsRegistry, "WeatherPrediction: Temperature in Celsius: 0.1 precision: Denver");
        console2.log("WeatherPrediction(Denver) deployed at:", address(weatherPredictionD));

        WeatherPrediction weatherPredictionN = new WeatherPrediction(executorsRegistry, "WeatherPrediction: Temperature in Celsius: 0.1 precision: New York");
        console2.log("WeatherPrediction(New York) deployed at:", address(weatherPredictionN));

        WeatherPrediction weatherPredictionH = new WeatherPrediction(executorsRegistry, "WeatherPrediction: Temperature in Celsius: 0.1 precision: Hong Kong");
        console2.log("WeatherPrediction(Hong Kong) deployed at:", address(weatherPredictionH));

        PriceFeedPrediction priceFeedPredictionB = new PriceFeedPrediction(executorsRegistry, "PriceFeedPrediction: 0 precision: BTC/USD");
        console2.log("PriceFeedPrediction(BTC/USD) deployed at:", address(priceFeedPredictionB));

        PriceFeedPrediction priceFeedPredictionE = new PriceFeedPrediction(executorsRegistry, "PriceFeedPrediction: 0 precision: ETH/USD");
        console2.log("PriceFeedPrediction(ETH/USD) deployed at:", address(priceFeedPredictionE));

        RandomPrediction randomPrediction = new RandomPrediction(executorsRegistry, "RandomPrediction: Random number between 0 and totalTickets");
        console2.log("RandomPrediction deployed at:", address(randomPrediction));

        vm.stopBroadcast();
    }
}
