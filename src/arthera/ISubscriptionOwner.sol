// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

interface ISubscriptionOwner {
    function getSubscriptionOwner() external view returns (address);
}
