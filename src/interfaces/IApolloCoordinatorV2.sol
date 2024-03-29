// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.20;

interface IApolloCoordinatorV2 {
    function requestDataFeed(string memory dataFeedId, uint256 callbackGasLimit) external;
    function requestRandomFeed(string memory dataFeedId, uint256 callbackGasLimit, uint256 numWords) external;

    event DataFeedRequested(
        uint256 indexed requestId, string dataFeedId, uint256 callbackGasLimit, address indexed requester
    );

    event RandomFeedRequested(
        uint256 indexed requestId, string dataFeedId, uint256 callbackGasLimit, uint256 numWords, address indexed requester
    );
}
