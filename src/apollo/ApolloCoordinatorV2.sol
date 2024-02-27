// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.20;

import {IApolloCoordinatorV2} from "../interfaces/IApolloCoordinatorV2.sol";

/**
 * @title ApolloCoordinator
 * @dev This contract allows consumer contracts to request data from the Apollo Network.
 */
contract ApolloCoordinatorV2 is IApolloCoordinatorV2 {
    /**
     * @notice Requests data from the Apollo network.
     * @param dataFeedId The identifier of the data feed being requested.
     * @param callbackGasLimit The gas limit for the callback transaction.
     */
    function requestDataFeed(
        string calldata dataFeedId,
        uint256 callbackGasLimit
    ) external {
        emit PriceFeedRequested(dataFeedId, callbackGasLimit, msg.sender);
    }
}
