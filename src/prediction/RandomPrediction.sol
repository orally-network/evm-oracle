// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {PredictionGeneric} from "./PredictionGeneric.sol";

// random number is getting in a range of totalTickets
contract RandomPrediction is PredictionGeneric {

    constructor(address _executorsRegistry, string memory _description) PredictionGeneric(_executorsRegistry, _description) {
    }

    function bid(uint) override public payable {
        require(auctionOpen, "Auction is not open.");
        uint ticketCount = msg.value / ticketPrice;
        require(ticketCount > 0, "Insufficient amount for any tickets.");
        require(msg.value == ticketCount * ticketPrice, "Send a correct amount of ETH.");

        for (uint i = 0; i < ticketCount; i++) {
            uint _numericGuess = totalTickets + 1;

            if (guessIndex[_numericGuess].length == 0) {
                activeGuesses.push(_numericGuess); // Track new active guess
            }

            Bid memory newBid = Bid({
                numericGuess: _numericGuess,
                ticketCount: 1,
                bidderAddress: msg.sender
            });

            guessIndex[_numericGuess].push(newBid);
            totalTickets += 1;

            emit BidPlaced(msg.sender, _numericGuess, 1, currentDay);
        }
    }

    function multiBid(MultiBid[] memory) override public payable {
        revert("MultiBid is not supported in RandomPrediction");
    }

    // for adapting data if needed
    function updateRandomNumeric(uint256 randomNumeric) public onlyExecutor {
        uint random = randomNumeric % totalTickets;

        updateNumeric("random", random, 0, block.timestamp);
    }
}
