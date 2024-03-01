// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import "wormhole-solidity-sdk/interfaces/IWormholeRelayer.sol";
import "wormhole-solidity-sdk/interfaces/IWormholeReceiver.sol";

uint16 constant ARBITRUM_WORMHOLE_CHAIN_ID = 23;
uint32 constant GAS_LIMIT = 500000;

contract CrossChainBidder is IWormholeReceiver {
    IWormholeRelayer public immutable wormholeRelayer;
    address public targetAddress;
    mapping(address => uint) public userBalances;

    event CrossChainMessageReceived(uint16 sourceChain, uint32 winningNumeric, address winner, uint256 reward);

    constructor(address _wormholeRelayer, address _targetAddress) {
        wormholeRelayer = IWormholeRelayer(_wormholeRelayer);
        targetAddress = _targetAddress;
    }

    function bid(uint32 numericGuess) external {
        sendCrossChainBid(
            ARBITRUM_WORMHOLE_CHAIN_ID,
            targetAddress,
            msg.value,
            numericGuess
        );
    }

    function receiveWormholeMessages(
        bytes memory payload,
        bytes[] memory, // additionalVaas
        bytes32, // address that called 'sendPayloadToEvm' (HelloWormhole contract address)
        uint16 sourceChain,
        bytes32 // unique identifier of delivery
    ) public payable override {
        require(msg.sender == address(wormholeRelayer), "Only relayer allowed");

        // Parse the payload and do the corresponding actions!
        (uint256 reward, uint32 winningNumeric, address winner) = abi.decode(
            payload,
            (uint256, uint256, address)
        );

        userBalances[winner] += reward;

        emit CrossChainMessageReceived(sourceChain, winningNumeric, winner, reward);
    }

    function quoteCrossChainGreeting(
        uint16 targetChain
    ) public view returns (uint256 cost) {
        (cost, ) = wormholeRelayer.quoteEVMDeliveryPrice(
            targetChain,
            0,
            GAS_LIMIT
        );
    }

    function sendCrossChainBid(
        uint16 targetChain,
        address _targetAddress,
        uint256 value,
        uint32 numericGuess
    ) public payable {
        uint256 cost = quoteCrossChainGreeting(targetChain);
//        require(msg.value == cost);
        wormholeRelayer.sendPayloadToEvm{value: cost}(
            targetChain,
            _targetAddress,
            abi.encode(value, numericGuess, msg.sender), // payload
            0, // no receiver value needed since we're just passing a message
            GAS_LIMIT
        );
    }
}
