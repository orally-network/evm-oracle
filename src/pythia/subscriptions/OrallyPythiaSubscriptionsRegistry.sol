// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {IOrallyPythiaSubscriptionsRegistry} from "./IOrallyPythiaSubscriptionsRegistry.sol";

/**
 * @title OrallyPythiaSubscriptionsRegistry
 * @notice A registry of subscriptions to Orally Pythia
 */
contract OrallyPythiaSubscriptionsRegistry {
    uint256 public nextSubscriptionId;
    mapping(uint256 => address) public subscriptionIdToSubscriber;
    mapping(uint256 => bool) public subscriptionActive;

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
        public
    {
        uint256 subscription_id = nextSubscriptionId;
        nextSubscriptionId++;
        subscriptionIdToSubscriber[subscription_id] = msg.sender;
        subscriptionActive[subscription_id] = true;
        emit newSubscription(subscription_id, msg.sender, target, method, frequency, is_random, pair_id);
    }

    function unsubscribe(uint256 subscription_id) public {
        require(subscriptionIdToSubscriber[subscription_id] == msg.sender, "Only the subscriber can unsubscribe");
        subscriptionActive[subscription_id] = false;
        emit subscriptionUnsubscribed(subscription_id);
    }
}
