# Path: orally-sdk-solidity/contracts

cp ../src/apollo/ApolloReceiver.sol ./
cp ../src/apollo/IApolloCoordinator.sol ./
cp ../src/registry/IOrallyExecutorsRegistry.sol ./
cp ../src/sybil/IOrallyVerifierOracle.sol ./
cp ../src/apollo/OrallyApolloConsumer.sol ./
cp ../src/pythia/OrallyPythiaConsumer.sol ./
cp ../src/OrallyStructs ./

forge build --silent
jq '.abi' ../my-output-dir/ApolloReceiver.sol/ApolloReceiver.json > ./abis/ApolloReceiver.json
jq '.abi' ../my-output-dir/IApolloCoordinator.sol/IApolloCoordinator.json > ./abis/IApolloCoordinator.json
jq '.abi' ../my-output-dir/IOrallyExecutorsRegistry.sol/IOrallyExecutorsRegistry.json > ./abis/IOrallyExecutorsRegistry.json
jq '.abi' ../my-output-dir/IOrallyVerifierOracle.sol/IOrallyVerifierOracle.json > ./abis/IOrallyVerifierOracle.json
jq '.abi' ../my-output-dir/OrallyApolloConsumer.sol/OrallyApolloConsumer.json > ./abis/OrallyApolloConsumer.json
jq '.abi' ../my-output-dir/OrallyPythiaConsumer.sol/OrallyPythiaConsumer.json > ./abis/OrallyPythiaConsumer.json
jq '.abi' ../my-output-dir/OrallyStructs.sol/OrallyStructs.json > ./abis/OrallyStructs.json

