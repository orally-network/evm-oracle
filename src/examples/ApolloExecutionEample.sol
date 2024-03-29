pragma solidity ^0.8.20;

import {OrallyApolloConsumer} from "../consumers/OrallyApolloConsumer.sol";
import {IApolloCoordinator} from "../interfaces/IApolloCoordinator.sol";

contract ApolloConsumerExample is OrallyApolloConsumer {
    uint256 public rate;
    uint256 public decimals;
    uint256 public timestamp;
    IApolloCoordinator public apollo;

    constructor(address _executorsRegistry, address _apolloCoordinator) OrallyApolloConsumer(_executorsRegistry) {
        apollo = IApolloCoordinator(_apolloCoordinator);
    }

    function requestValue() public {
        apollo.requestDataFeed("ICP/USD", 300000);
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
