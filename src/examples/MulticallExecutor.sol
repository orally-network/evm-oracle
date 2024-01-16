// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

contract MulticallExecutor {
    uint256 data;

    function updateData(uint256 _data) public {
        data = _data;

        emit DataUpdated(_data);
    }

    event DataUpdated(uint256 _data);
}
