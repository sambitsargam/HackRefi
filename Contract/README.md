# GreenChain Waste Recycling Contract

## Overview

This folder contains the smart contract code for GreenChain's waste recycling system. GreenChain is dedicated to providing innovative recycling solutions to the commercial and industrial sectors using web3 technology. The `Waste` contract tokenizes waste items and facilitates their trading and recycling through a decentralized marketplace.

## Contracts

### Waste.sol

The `Waste` contract is an ERC721 implementation that includes additional functionalities for listing, buying, and recycling waste tokens. It is designed to:

- **Tokenize Waste**: Waste items are minted as ERC721 tokens.
- **Marketplace for Waste**: Allows the creation, listing, and sale of tokenized waste items.
- **Recycling Tracking**: Tracks and updates the status of recycled items.
- **Reward Issuance**: Integrates with the Inverter Protocol to issue reward tokens for recycling actions.

### Dependencies

- [OpenZeppelin Contracts](https://openzeppelin.com/contracts/): Provides the base ERC721 implementation and utility functions.

## Structure

- `Waste.sol`: Main contract file containing the `Waste` contract.
- `interfaces/`: Contains interface files for external contracts such as the `Orchestrator` and `KPIRewarder`.

## Installation

To compile and deploy the `Waste` contract, follow these steps:

1. **Install Dependencies**: Ensure you have the necessary dependencies installed, including OpenZeppelin Contracts.
   ```bash
   npm install @openzeppelin/contracts
   ```

2. **Compile Contracts**: Use a Solidity compiler like `solc` or a development environment like Hardhat or Truffle to compile the contract.
   ```bash
   npx hardhat compile
   ```

3. **Deploy Contracts**: Deploy the contract to your preferred Ethereum network.
   ```bash
   npx hardhat run scripts/deploy.js --network <network-name>
   ```

## Usage

### Functions

#### `createToken`

Mints a new waste token and lists it in the marketplace.

```solidity
function createToken(string memory tokenURI, uint256 price) public payable returns (uint)
```

- `tokenURI`: URI of the token metadata.
- `price`: Listing price of the token.

#### `createMarketSale`

Facilitates the sale of a listed waste token.

```solidity
function createMarketSale(uint256 tokenId) public payable
```

- `tokenId`: ID of the token to be purchased.

#### `fetchMarketItems`

Returns all unsold market items.

```solidity
function fetchMarketItems() public view returns (MarketItem[] memory)
```

#### `fetchMyNFTs`

Returns items owned by the caller.

```solidity
function fetchMyNFTs() public view returns (MarketItem[] memory)
```

#### `fetchItemsListed`

Returns items listed by the caller.

```solidity
function fetchItemsListed() public view returns (MarketItem[] memory)
```

## Integration with Inverter Protocol

The contract integrates with the Inverter Protocol to issue reward tokens for recycling. This incentivizes recycling actions and promotes sustainability.

## Contributing

Contributions are welcome! Please fork the repository and create a pull request with your changes.

## License

This project is licensed under the MIT License. See the [LICENSE](../LICENSE) file for details.
