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
    uint256 public requestCounter;

    // All requests by ID
    mapping(uint256 => PriceFeedRequest) public requests;

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

    function _getRequestId() internal returns (uint256 requestId) {
        requestId = requestCounter;
        requestCounter++;
    }

    function getRequestsFromId(
        uint256 _start
    ) public view returns (PriceFeedRequest[] memory requestRange) {
        requestRange = getRequestsInRange(_start, requestCounter);
    }

    function getRequestsInRange(
        uint256 _start,
        uint256 _end
    ) public view returns (PriceFeedRequest[] memory requestRange) {
        requestRange = new PriceFeedRequest[](_end - _start);
        for (uint256 i = _start; i < _end; i++) {
            requestRange[i - _start] = requests[i];
        }
    }
}
