// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {OrallyPythiaConsumer} from "../consumers/OrallyPythiaConsumer.sol";

// temperature treats with decimals=1 (e.g. 25.5 = 255)
contract WeatherPredictionV2 is OrallyPythiaConsumer {
    uint256 public ticketPrice = 0.001 ether;
    address public owner;

    struct MultiBid {
        uint temperatureGuess;
        uint ticketCount;
    }

    struct Bid {
        uint temperatureGuess;
        uint ticketCount;
        address bidderAddress;
    }

    mapping(uint => Bid[]) private guessIndex;
    uint[] private activeGuesses; // Tracks the active guesses to iterate over

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
    event RoundClosed(uint day, uint totalTickets);
    event TicketPriceChanged(uint256 newTicketPrice);
    event FeePercentageChanged(uint newFeePercentage);

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
        uint ticketCount = msg.value / ticketPrice;
        require(ticketCount > 0, "Insufficient amount for any tickets.");
        require(msg.value == ticketCount * ticketPrice, "Send a correct amount of ETH.");

        if (guessIndex[_temperatureGuess].length == 0) {
            activeGuesses.push(_temperatureGuess); // Track new active guess
        }

        Bid memory newBid = Bid({
            temperatureGuess: _temperatureGuess,
            ticketCount: ticketCount,
            bidderAddress: msg.sender
        });

        guessIndex[_temperatureGuess].push(newBid);
        totalTickets += ticketCount;

        emit BidPlaced(msg.sender, _temperatureGuess, ticketCount, currentDay);
    }

    function multiBid(MultiBid[] memory bids) public payable {
        require(auctionOpen, "Auction is not open.");
        uint totalEthRequired = 0;

        for (uint i = 0; i < bids.length; i++) {
            totalEthRequired += bids[i].ticketCount * ticketPrice;
        }

        require(msg.value == totalEthRequired, "Incorrect ETH amount for bids.");

        for (uint i = 0; i < bids.length; i++) {
            uint _temperatureGuess = bids[i].temperatureGuess;
            uint ticketCount = bids[i].ticketCount;

            if (guessIndex[_temperatureGuess].length == 0) {
                activeGuesses.push(_temperatureGuess); // Track new active guess
            }

            Bid memory newBid = Bid({
                temperatureGuess: _temperatureGuess,
                ticketCount: ticketCount,
                bidderAddress: msg.sender
            });

            guessIndex[_temperatureGuess].push(newBid);
            totalTickets += ticketCount;

            emit BidPlaced(msg.sender, _temperatureGuess, ticketCount, currentDay);
        }
    }

    // close auction before providing winning temperature to avoid reentrancy attack
    function closeAuction() public onlyExecutor {
        auctionOpen = false;

        emit RoundClosed(currentDay, totalTickets);
    }

    function updateTemperature(string memory, uint256 _temperature, uint256 _decimals, uint256 _timestamp) public onlyExecutor {
        require(!auctionOpen, "Auction is still open.");
        currentTemperature = _temperature;
        lastUpdate = _timestamp;
        selectWinner();
    }

    function selectWinner() internal {
        uint closestDiff = type(uint).max;
        uint winningTemperature;
        uint totalWinningTickets = 0;

        for(uint i = 0; i < activeGuesses.length; i++) {
            uint guess = activeGuesses[i];

            if(guessIndex[guess].length > 0) {
                uint diff = absDifference(guess, currentTemperature);
                if (diff < closestDiff) {
                    closestDiff = diff;
                    winningTemperature = guess;

                    totalWinningTickets = sumTicketCounts(guessIndex[guess]);
                }
            }
        }

        if(totalWinningTickets > 0) {
            distributePrize(winningTemperature, totalWinningTickets);
        }

        clearBids();
    }

    function sumTicketCounts(Bid[] storage bids) internal view returns (uint totalTickets) {
        uint totalTickets = 0;

        for (uint i = 0; i < bids.length; i++) {
            totalTickets += bids[i].ticketCount;
        }

        return totalTickets;
    }

    function absDifference(uint a, uint b) internal pure returns(uint) {
        if(a >= b) return a - b;
        else return b - a;
    }

    function distributePrize(uint winningTemperature, uint totalWinningTickets) internal {
        uint prizePerTicket = totalTickets * ticketPrice / totalWinningTickets;
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

    function setTicketPrice(uint256 _ticketPrice) public onlyOwner {
        ticketPrice = _ticketPrice;
        emit TicketPriceChanged(_ticketPrice);
    }

    function setFeePercentage(uint _feePercentage) public onlyOwner {
        require(_feePercentage <= 20, "Fee percentage cannot exceed 20.");
        feePercentage = _feePercentage;
        emit FeePercentageChanged(_feePercentage);
    }

    function clearBids() internal {
        for(uint i = 0; i < activeGuesses.length; i++) {
            delete guessIndex[activeGuesses[i]];
        }
        delete activeGuesses; // Clear the list of active guesses
        totalTickets = 0;
        auctionOpen = true;
        currentDay++;
    }
}
