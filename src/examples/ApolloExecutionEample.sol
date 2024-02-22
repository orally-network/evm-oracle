import {OrallyApolloConsumer} from "../consumers/OrallyApolloConsumer.sol";
import {IApolloCoordinatorV2} from "../interfaces/IApolloCoordinatorV2.sol";

contract ApolloConsumerExample is OrallyApolloConsumer {
    uint256 public rate;
    uint256 public decimals;
    uint256 public timestamp;
    IApolloCoordinatorV2 public apollo;

    constructor(address _executorsRegistry, address _apolloCoordinator) OrallyApolloConsumer(_executorsRegistry) {
        apollo = IApolloCoordinatorV2(_apolloCoordinator);
    }

    function requestValue() public {
        apollo.requestDataFeed("ICP/USD", 300000);
    }

    function fulfillDataFeed(string memory, uint256 _rate, uint256 _decimals, uint256 _timestamp) external onlyExecutor {
        rate = _rate;
        decimals = _decimals;
        timestamp = _timestamp;
    }
}
