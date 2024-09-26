# contract

TokenV1 and TokenProxy is deprecated.
Seiyan.fun is now using TokenV2.
When a user create a new token, seyian.fun deploy a new token via [Clones.cloneDeterministic](https://docs.openzeppelin.com/contracts/4.x/api/proxy#Clones-cloneDeterministic-address-bytes32-) because of gas fee optimization. (Not upgradeable contract)


## TokenV2 Implementation

- address: `0x3f08b8b14a2A06c2f589074e1d03f2AC85980879`
