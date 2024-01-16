// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.20;

interface IApolloCoordinator {
    struct PriceFeedRequest {
        bytes32 requestId; // Unique identifier for the request
        string dataFeedId; // Identifier for the type of data requested
        uint256 callbackGasLimit; // Gas limit for the callback transaction
        address requester; // Address of the requesting contract
    }

    event PriceFeedRequested(
        bytes32 indexed requestId, string indexed dataFeedId, uint256 callbackGasLimit, address indexed requester
    );
}
