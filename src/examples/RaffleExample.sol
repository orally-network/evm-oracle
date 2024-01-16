// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {OrallyPythiaConsumer} from "../consumers/OrallyPythiaConsumer.sol";

contract RaffleExample is OrallyPythiaConsumer {
    uint256 maxNumberOfTickets;
    uint256 ticketPrice;
    address[] entries;

    constructor(address _pythiaRegistry, uint256 _maxNumberOfTickets, uint256 _ticketPrice)
        OrallyPythiaConsumer(_pythiaRegistry)
    {
        maxNumberOfTickets = _maxNumberOfTickets;
        ticketPrice = _ticketPrice;
    }

    function enterRaffle() external payable {
        require(entries.length < maxNumberOfTickets, "RaffleExample: Raffle is full");
        require(msg.value == ticketPrice, "RaffleExample: Ticket price is not correct");
        entries.push(msg.sender);
    }

    function pickWinner(uint256 _randomNumber) external onlyExecutor {
        require(entries.length == maxNumberOfTickets, "RaffleExample: Raffle is not full");
        uint256 winnerIndex = _randomNumber % entries.length;
        (bool success,) = payable(entries[winnerIndex]).call{value: address(this).balance}("");

        require(success, "RaffleExample: Failed to send Ether to winner");
    }
}
