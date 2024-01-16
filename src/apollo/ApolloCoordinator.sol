// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.20;

import {IApolloCoordinator} from "../interfaces/IApolloCoordinator.sol";

/**
 * @title ApolloCoordinator
 * @dev This contract allows consumer contracts to request data from the Apollo Network.
 * It is similar in structure to Chainlink's VRFCoordinatorV2, but tailored for the Apollo system.
 */
contract ApolloCoordinator is IApolloCoordinator {
    // Counter for generating unique request IDs
    uint256 private requestCounter;

    /**
     * NOTES:
     * requestDataFeed probably needs a address target argument as well,
     * but the user in charge of the Orally account should link that address
     * to his account with some kind of registry.
     */

    /**
     * @notice Requests data from the Apollo network.
     * @param dataFeedId The identifier of the data feed being requested.
     * @param callbackGasLimit The gas limit for the callback transaction.
     */
    function requestDataFeed(string memory dataFeedId, uint256 callbackGasLimit) public {
        emit PriceFeedRequested(_getRequestId(), dataFeedId, callbackGasLimit, msg.sender);
    }

    function _getRequestId() internal returns (bytes32 requestId) {
        // Generate a unique request ID
        requestId = keccak256(abi.encodePacked(address(this), requestCounter));
        requestCounter++;
    }

    // Additional functions and modifiers as needed for your Apollo system...
}
