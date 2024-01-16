// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {OrallyPythiaConsumer} from "../consumers/OrallyPythiaConsumer.sol";
import {ISubscriptionOwner} from "./ISubscriptionOwner.sol";
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";

contract ArtheraMulticall is OrallyPythiaConsumer, ISubscriptionOwner, ERC165 {
    constructor(address _executorsRegistry) OrallyPythiaConsumer(_executorsRegistry) {}

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

    function multicall(Call[] calldata calls) public onlyExecutor returns (Result[] memory) {
        uint256 length = calls.length;
        Result[] memory returnData = new Result[](length);
        uint256 gasBefore;
        for (uint256 i = 0; i < length; i++) {
            gasBefore = gasleft();
            //            if (gasBefore < (calls[i].gasLimit + 1000)) {
            //                return returnData;
            //            }

            Result memory result = returnData[i];
            (result.success, result.returnData) = calls[i].target.call(calls[i].callData);
            result.usedGas = gasBefore - gasleft();
            returnData[i] = result;
        }

        return returnData;
    }

    function multitransfer(Transfer[] calldata transfers) public payable onlyExecutor {
        for (uint256 i = 0; i < transfers.length; i++) {
            payable(transfers[i].target).transfer(transfers[i].value);
        }
    }

    function getSubscriptionOwner() external pure returns (address) {
        // the owner of the subscription must be an EOA
        // Replace this with the account created in Step 1
        // deployer contract
        return 0x34E057b970D7c230a5e46c7A78C63A370d76c284;
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC165) returns (bool) {
        return interfaceId == type(ISubscriptionOwner).interfaceId || super.supportsInterface(interfaceId);
    }
}
