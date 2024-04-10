// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

interface IOrallyPythiaSubscriptionsRegistry {
    function nextSubscriptionId() external view returns (uint256);

    function subscriptionIdToSubscriber(uint256) external view returns (address);

    function subscriptionActive(uint256) external view returns (bool);

    function unsubscribe(uint256 subscription_id) external;

    event newSubscription(
        uint256 indexed subscription_id,
        address indexed subscriber,
        address indexed target,
        string method,
        uint256 frequency,
        bool is_random,
        string pair_id
    );

    event subscriptionUnsubscribed(uint256 indexed subscription_id);

    function subscribe(address target, string memory method, uint256 frequency, bool is_random, string memory pair_id)
        external;
}
