// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IOrchestrator {
    function executeAction(address target, bytes calldata data) external returns (bytes memory);
}

interface IKPIRewarder {
    function issueRewards(address to, uint256 amount) external;
}

contract Waste is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _itemsRecycled;

    address payable owner;
    IERC20 public rewardToken;
    IOrchestrator public orchestrator;
    IKPIRewarder public kpiRewarder;

    mapping(uint256 => MarketItem) private idToMarketItem;

    struct MarketItem {
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool recycled;
    }

    event MarketItemCreated (
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool recycled
    );

    event TokensIssued (
        address indexed to,
        uint256 amount
    );

    constructor(
        address _rewardTokenAddress,
        address _orchestratorAddress,
        address _kpiRewarderAddress
    ) ERC721("Recycle", "RCY") {
        owner = payable(msg.sender);
        rewardToken = IERC20(_rewardTokenAddress);
        orchestrator = IOrchestrator(_orchestratorAddress);
        kpiRewarder = IKPIRewarder(_kpiRewarderAddress);
    }

    /* Mints a waste and lists it in the marketplace */
    function createToken(string memory tokenURI, uint256 price) public payable returns (uint) {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();

        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        createMarketItem(newTokenId, price);
        return newTokenId;
    }

    function createMarketItem(uint256 tokenId, uint256 price) private {
        require(price >= 0, "Price must be at least 0 wei");
        idToMarketItem[tokenId] = MarketItem(
            tokenId,
            payable(msg.sender),
            payable(address(this)),
            price,
            false
        );

        _transfer(msg.sender, address(this), tokenId);
        emit MarketItemCreated(
            tokenId,
            msg.sender,
            address(this),
            price,
            false
        );
    }

    // Transfers ownership of the item, as well as funds between parties 
    function createMarketSale(uint256 tokenId) public payable {
        uint price = idToMarketItem[tokenId].price;
        address seller = idToMarketItem[tokenId].seller;
        require(msg.value == price, "Please submit the asking price in order to complete the purchase");

        idToMarketItem[tokenId].owner = payable(msg.sender);
        idToMarketItem[tokenId].recycled = true;
        idToMarketItem[tokenId].seller = payable(address(0));
        _itemsRecycled.increment();
        _transfer(address(this), msg.sender, tokenId);
        payable(seller).transfer(msg.value);

        // Issue tokens as rewards for recycling
        uint256 rewardAmount = calculateReward(price);
        
        // Call the orchestrator to execute the KPI Rewarder
        orchestrator.executeAction(
            address(kpiRewarder),
            abi.encodeWithSignature("issueRewards(address,uint256)", msg.sender, rewardAmount)
        );
        emit TokensIssued(msg.sender, rewardAmount);
    }

    // Calculate reward based on price or other metrics
    function calculateReward(uint256 price) internal pure returns (uint256) {
        // Example: reward 1 token per 1 ether value of waste
        return price / 1 ether;
    }

    /* Returns all unsold market items */
    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint itemCount = _tokenIds.current();
        uint unsoldItemCount = _tokenIds.current() - _itemsRecycled.current();
        uint currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        for (uint i = 0; i < itemCount; i++) {
            if (idToMarketItem[i + 1].owner == address(this)) {
                uint currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    /* Returns only items that a user has purchased */
    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint totalItemCount = _tokenIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                uint currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    /* Returns only items a user has listed */
    function fetchItemsListed() public view returns (MarketItem[] memory) {
        uint totalItemCount = _tokenIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == msg.sender) {
                uint currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }
}
