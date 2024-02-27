// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.20;

interface IApolloCoordinatorV2 {
    function requestDataFeed(string memory dataFeedId, uint256 callbackGasLimit) external;

    event PriceFeedRequested(
        string dataFeedId, uint256 callbackGasLimit, address indexed requester
    );
}
