// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {OrallyConsumer} from "./consumers/OrallyConsumer.sol";

contract OrallyMulticall is OrallyConsumer {
    constructor(
        address _executorsRegistry
    ) OrallyConsumer(_executorsRegistry) {}

    struct Call {
        address target;
        bytes callData;
        uint256 gasLimit;
    }

    struct Transfer {
        address target;
        uint256 value;
    }

    struct Result {
        bool success;
        uint256 usedGas;
        bytes returnData;
    }

    event MulticallExecuted(Result[] resultExecutionData);

    function multicall(
        Call[] calldata calls
    ) public onlyExecutor returns (Result[] memory) {
        uint256 length = calls.length;
        Result[] memory returnData = new Result[](length);
        uint256 gasBefore;
        for (uint256 i = 0; i < length; i++) {
            gasBefore = gasleft();
            if (gasBefore < (calls[i].gasLimit + 1000) && length != 1) {
                return returnData;
            }

            Result memory result = returnData[i];
            (result.success, result.returnData) = calls[i].target.call(
                calls[i].callData
            );
            result.usedGas = gasBefore - gasleft();
            returnData[i] = result;
        }

        emit MulticallExecuted(returnData);

        return returnData;
    }

    function multitransfer(Transfer[] calldata transfers) public payable {
        for (uint256 i = 0; i < transfers.length; i++) {
            payable(transfers[i].target).transfer(transfers[i].value);
        }
    }
}
