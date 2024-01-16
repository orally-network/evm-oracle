// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {console2} from "forge-std/console2.sol";

contract Counter {
    uint256 public price;
    uint64 public random;
    uint64 public counter = 0;

    address public last_caller;

    function set_price(string memory, uint256 _price, uint256, uint256) public {
        last_caller = msg.sender;
        price = _price;
    }

    function set_random(uint64 _random) public {
        last_caller = msg.sender;
        random = _random;
    }

    function increment_counter() public {
        last_caller = msg.sender;
        counter++;
        console2.log("increment_counter");
        console2.log(msg.sender);
    }
}
