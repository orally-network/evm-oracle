// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.20;

import {IApolloCoordinator} from "../interfaces/IApolloCoordinator.sol";

/**
 * @title ApolloCoordinator
 * @dev This contract allows consumer contracts to request data from the Apollo Network.
 */
contract ApolloCoordinatorV2 is IApolloCoordinator {
    /**
     * @notice Requests data from the Apollo network.
     * @param dataFeedId The identifier of the data feed being requested.
     * @param callbackGasLimit The gas limit for the callback transaction.
     */
    function requestDataFeed(string memory dataFeedId, uint256 callbackGasLimit) public {
        emit PriceFeedRequested(id, dataFeedId, callbackGasLimit, msg.sender);
    }
}
