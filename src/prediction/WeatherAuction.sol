// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {OrallyPythiaConsumer} from "../consumers/OrallyPythiaConsumer.sol";

// temperature treats with decimals=1 (e.g. 25.5 = 255)
contract WeatherAuction is OrallyPythiaConsumer {
    uint256 constant TICKET_PRICE = 0.001 ether;
    address public owner;
    struct Bid {
        uint temperatureGuess;
        uint ticketCount;
        address bidderAddress;
    }
    mapping(uint => Bid[]) private guessIndex;
    mapping(address => uint) public userBalances;
    uint public currentTemperature;
    uint public currentDay = 0;
    bool public auctionOpen;
    uint public totalTickets;
    uint public feePercentage = 5;
    uint256 public lastUpdate;

    event BidPlaced(address indexed bidder, uint temperatureGuess, uint ticketCount, uint day);
    event WinnerDeclared(address winner, uint day, uint temperature, uint winnerPrize);
    event Withdrawal(address indexed user, uint amount);

    constructor(address _executorsRegistry) OrallyPythiaConsumer(_executorsRegistry) {
        owner = msg.sender;
        auctionOpen = true;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    function bid(uint _temperatureGuess) public payable {
        require(auctionOpen, "Auction is not open.");
        uint ticketCount = msg.value / TICKET_PRICE;
        require(ticketCount > 0, "Insufficient amount for any tickets.");
        require(msg.value == ticketCount * TICKET_PRICE, "Send a correct amount of ETH.");

        Bid memory newBid = Bid({
            temperatureGuess: _temperatureGuess,
            ticketCount: ticketCount,
            bidderAddress: msg.sender
        });

        guessIndex[_temperatureGuess].push(newBid);
        totalTickets += ticketCount;

        emit BidPlaced(msg.sender, _temperatureGuess, ticketCount, currentDay);
    }

    // close auction before providing winning temperature to avoid reentrancy attack
    function closeAuction() public onlyExecutor {
        require(totalTickets > 0, "No tickets sold for today.");
        auctionOpen = false;
    }

    function updateTemperature(string memory, uint256 _temperature, uint256 _decimals, uint256 _timestamp) public onlyExecutor {
        require(totalTickets > 0, "No tickets sold for today.");
        require(!auctionOpen, "Auction is still open.");
        currentTemperature = _temperature;
        lastUpdate = _timestamp;
        selectWinner();
    }

    function selectWinner() internal {
        uint closestDiff = type(uint).max;
        uint winningTemperature;
        uint totalWinningTickets = 0;

        for(uint i = 0; i < 500; i++) {  // Assuming temperature range 0-49.9C for simplicity
            if(guessIndex[i].length > 0) {
                uint diff = absDifference(i, currentTemperature);
                if (diff < closestDiff) {
                    closestDiff = diff;
                    winningTemperature = i;
                    totalWinningTickets = 0;
                    for (uint j = 0; j < guessIndex[i].length; j++) {
                        totalWinningTickets += guessIndex[i][j].ticketCount;
                    }
                }
            }
        }

        if(totalWinningTickets > 0) {
            distributePrize(winningTemperature, totalWinningTickets);
        }

        clearBids();
    }

    function absDifference(uint a, uint b) internal pure returns(uint) {
        if(a >= b) return a - b;
        else return b - a;
    }

    function distributePrize(uint winningTemperature, uint totalWinningTickets) internal {
        uint prizePerTicket = totalTickets * TICKET_PRICE / totalWinningTickets;
        for (uint i = 0; i < guessIndex[winningTemperature].length; i++) {
            Bid memory winnerBid = guessIndex[winningTemperature][i];
            address winner = winnerBid.bidderAddress;
            uint winnerPrize = prizePerTicket * winnerBid.ticketCount;
            uint fee = winnerPrize / 100 * feePercentage;
            userBalances[owner] += fee;
            userBalances[winner] += (winnerPrize - fee);

            emit WinnerDeclared(winner, currentDay, winningTemperature, winnerPrize);
        }
    }

    function withdraw() public {
        uint amount = userBalances[msg.sender];
        require(amount > 0, "No balance to withdraw.");

        userBalances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);

        emit Withdrawal(msg.sender, amount);
    }

    // Withdraw function for contract owner
    function ownerWithdraw() public onlyOwner {
        uint amount = address(this).balance;
        payable(owner).transfer(amount);
    }

    function clearBids() internal {
        for(uint i = 0; i < 500; i++) {  // Assuming temperature range 0-49.9C for simplicity
            delete guessIndex[i];
        }
        totalTickets = 0;
        auctionOpen = true;
        currentDay++;
    }
}
