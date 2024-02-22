// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {OrallyConsumer} from "../consumers/OrallyConsumer.sol";

contract PredictionGeneric is OrallyConsumer {
    uint256 public ticketPrice = 0.0015 ether;
    address public owner;

    struct MultiBid {
        uint numericGuess;
        uint ticketCount;
    }

    struct Bid {
        uint numericGuess;
        uint ticketCount;
        address bidderAddress;
    }

    mapping(uint => Bid[]) public guessIndex;
    uint[] public activeGuesses; // Tracks the active guesses to iterate over

    mapping(address => uint) public userBalances;
    uint public currentNumeric;
    uint public currentDay = 0;
    bool public auctionOpen;
    uint public totalTickets;
    uint public feePercentage = 10;
    uint256 public lastUpdate;
    string public dataFeedId;
    string public description;

    event BidPlaced(address indexed bidder, uint numericGuess, uint ticketCount, uint day);
    event WinnerDeclared(address winner, uint day, uint numericGuess, uint winnerPrize);
    event Withdrawal(address indexed user, uint amount);
    event RoundClosed(uint day, uint totalTickets);
    event TicketPriceChanged(uint256 newTicketPrice);
    event FeePercentageChanged(uint newFeePercentage);
    event DescriptionChanged(string newDescription);

    constructor(address _executorsRegistry, string memory _description) OrallyConsumer(_executorsRegistry) {
        owner = msg.sender;
        description = _description;
        auctionOpen = true;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    function bid(uint _numericGuess) virtual public payable {
        require(auctionOpen, "Auction is not open.");
        uint ticketCount = msg.value / ticketPrice;
        require(ticketCount > 0, "Insufficient amount for any tickets.");
        require(msg.value == ticketCount * ticketPrice, "Send a correct amount of ETH.");

        if (guessIndex[_numericGuess].length == 0) {
            activeGuesses.push(_numericGuess); // Track new active guess
        }

        Bid memory newBid = Bid({
            numericGuess: _numericGuess,
            ticketCount: ticketCount,
            bidderAddress: msg.sender
        });

        guessIndex[_numericGuess].push(newBid);
        totalTickets += ticketCount;

        emit BidPlaced(msg.sender, _numericGuess, ticketCount, currentDay);
    }

    function multiBid(MultiBid[] memory bids) virtual public payable {
        require(auctionOpen, "Auction is not open.");
        uint totalEthRequired = 0;

        for (uint i = 0; i < bids.length; i++) {
            totalEthRequired += bids[i].ticketCount * ticketPrice;
        }

        require(msg.value == totalEthRequired, "Incorrect ETH amount for bids.");

        for (uint i = 0; i < bids.length; i++) {
            uint _numericGuess = bids[i].numericGuess;
            uint ticketCount = bids[i].ticketCount;

            if (guessIndex[_numericGuess].length == 0) {
                activeGuesses.push(_numericGuess); // Track new active guess
            }

            Bid memory newBid = Bid({
                numericGuess: _numericGuess,
                ticketCount: ticketCount,
                bidderAddress: msg.sender
            });

            guessIndex[_numericGuess].push(newBid);
            totalTickets += ticketCount;

            emit BidPlaced(msg.sender, _numericGuess, ticketCount, currentDay);
        }
    }

    // close auction before providing winning numeric to avoid reentrancy attack
    function closeAuction() public onlyExecutor {
        auctionOpen = false;

        emit RoundClosed(currentDay, totalTickets);
    }

    function updateNumeric(string memory _dataFeedId, uint256 _numeric, uint256, uint256 _timestamp) public onlyExecutor {
        require(!auctionOpen, "Auction is still open.");
        currentNumeric = _numeric;
        lastUpdate = _timestamp;
        dataFeedId = _dataFeedId;
        selectWinner();
    }

    function selectWinner() internal {
        uint closestDiff = type(uint).max;
        uint winningNumeric;
        uint totalWinningTickets = 0;

        for(uint i = 0; i < activeGuesses.length; i++) {
            uint guess = activeGuesses[i];

            if(guessIndex[guess].length > 0) {
                uint diff = absDifference(guess, currentNumeric);
                if (diff < closestDiff) {
                    closestDiff = diff;
                    winningNumeric = guess;

                    totalWinningTickets = sumTicketCounts(guessIndex[guess]);
                }
            }
        }

        if(totalWinningTickets > 0) {
            distributePrize(winningNumeric, totalWinningTickets);
        }

        clearBids();
    }

    function sumTicketCounts(Bid[] storage bids) internal view returns (uint tickets) {
        for (uint i = 0; i < bids.length; i++) {
            tickets += bids[i].ticketCount;
        }

        return tickets;
    }

    function absDifference(uint a, uint b) internal pure returns(uint) {
        if(a >= b) return a - b;
        else return b - a;
    }

    function distributePrize(uint winningNumeric, uint totalWinningTickets) internal {
        uint prizePerTicket = totalTickets * ticketPrice / totalWinningTickets;
        for (uint i = 0; i < guessIndex[winningNumeric].length; i++) {
            Bid memory winnerBid = guessIndex[winningNumeric][i];
            address winner = winnerBid.bidderAddress;
            uint winnerPrize = prizePerTicket * winnerBid.ticketCount;
            uint fee = winnerPrize / 100 * feePercentage;
            userBalances[owner] += fee;
            userBalances[winner] += (winnerPrize - fee);

            emit WinnerDeclared(winner, currentDay, winningNumeric, winnerPrize);
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

    function setDescription(string memory _description) public onlyOwner {
        description = _description;
        emit DescriptionChanged(_description);
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
