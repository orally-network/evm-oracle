pragma solidity ^0.8.20;

import {ApolloReceiver} from "../apollo/ApolloReceiver.sol";

contract ApolloConsumerExample is ApolloReceiver {
    uint256 public rate;
    uint256 public decimals;
    uint256 public timestamp;

    constructor(address _executorsRegistry, address _apolloCoordinator) ApolloReceiver(_executorsRegistry, _apolloCoordinator) {}

    function requestValue() public {
        apolloCoordinator.requestDataFeed("ICP/USD", 300000);
    }

    function fulfillDataFeed(
        string memory,
        uint256 _rate,
        uint256 _decimals,
        uint256 _timestamp
    ) external onlyExecutor {
        rate = _rate;
        decimals = _decimals;
        timestamp = _timestamp;
    }
}
