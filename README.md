Real State ERC721
===========================

![GitHub repo size](https://img.shields.io/github/repo-size/Luan-Web3/real-state-erc721?style=for-the-badge)
![GitHub language count](https://img.shields.io/github/languages/count/Luan-Web3/real-state-erc721?style=for-the-badge)
![GitHub forks](https://img.shields.io/github/forks/Luan-Web3/real-state-erc721?style=for-the-badge)

This project is a smart contract developed in Solidity that uses the **ERC721 standard** to tokenize real estate properties on the blockchain. The main idea is to bring the real estate world into a decentralized environment, enabling the creation, rental, and management of properties in a secure and transparent manner.

[Sepolia Contract Address](https://sepolia.etherscan.io/address/0xa5535482CcEC479bd585E4A43CB17856F82C6ca1)

## Prerequisites

Before you begin, make sure you meet the following requirements:

- [Foundry](https://book.getfoundry.sh/getting-started/installation)

## Instructions to Run

```
git clone https://github.com/Luan-Web3/real-state-erc721.git
```
```
cd real-state-erc721
```
- Open 2 terminals

### Terminal A
```
anvil
```

### Terminal B
Run a smart contract as a script:
```
forge script script/RealStateNFT.s.sol --rpc-url localhost:8545 --private-key <OWNER_CONTRACT> --broadcast
```
Mint a new token
```
cast send <CONTRACT_ADDRESS> "mintProperty(uint256,uint256,uint8)" 20ether 1ether 5 --rpc-url localhost:8545 --private-key <OWNER_CONTRACT>
```
Return all property ids
```
cast call <CONTRACT_ADDRESS> "getAllPropertyIds()(uint256[])" --rpc-url localhost:8545
```
Return a property by id
```
cast call <CONTRACT_ADDRESS> "properties(uint256)(uint256,uint256,uint256,uint8,address,uint256)" <PROPERTY_ID> --rpc-url localhost:8545
```
Return the owner of the property
```
cast call <CONTRACT_ADDRESS> "ownerOf(uint256)(address)" <PROPERTY_ID> --rpc-url localhost:8545
```
Return the balance of the account
```
cast balance <ACCOUNT_PUBLIC_KEY> --rpc-url localhost:8545
```
Buy a property
```
cast send <CONTRACT_ADDRESS> "buyProperty(uint256)" <PROPERTY_ID> --value 20ether --rpc-url localhost:8545 --private-key <OTHER_ACCOUNT>
```
Rent a property
```
cast send <CONTRACT_ADDRESS> "rentProperty(uint256)" <PROPERTY_ID> --value 1ether --rpc-url localhost:8545 --private-key <OTHER_ACCOUNT>
```
Pay a rent
```
cast send <CONTRACT_ADDRESS> "payRent(uint256)" <PROPERTY_ID> --value 1ether --rpc-url localhost:8545 --private-key <OTHER_ACCOUNT>
```
Return a invoice by property id
```
cast call <CONTRACT_ADDRESS> "rentInvoices(uint256)(uint256,uint256,uint8)" <PROPERTY_ID> --rpc-url localhost:8545
```
Cancel a rent
```
cast send <CONTRACT_ADDRESS> "cancelRent(uint256)" <PROPERTY_ID> --rpc-url localhost:8545 --private-key <OTHER_ACCOUNT>
```

## Testing
```
forge test -vvvv
```

## License

<sup>
Licensed under either of <a href="LICENSE-APACHE">Apache License, Version
2.0</a> or <a href="LICENSE-MIT">MIT license</a> at your option.
</sup>

<br>

<sub>
Unless you explicitly state otherwise, any contribution intentionally submitted
for inclusion in this crate by you, as defined in the Apache-2.0 license, shall
be dual licensed as above, without any additional terms or conditions.
</sub>
