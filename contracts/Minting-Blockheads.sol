// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./token/ERC721/extensions/ERC721Enumerable.sol";
import "./utils/Strings.sol";

abstract contract BlockheadsForAuction {
    function ownerOf(uint256 tokenId) public view virtual returns (address);
    function mintBlockhead(address userAddress, uint256 tokenId, uint256 tokenData) public virtual;
    function finalized() public view virtual returns (bool);
}

contract MintingBlockheads {
    
    uint256 constant BLOCKHEADS_COUNT = 1992;
    uint256 constant AUCTION_CLUSTER_SIZE = 24;
    uint256 constant AUCTION_CLUSTER_COUNT = 83;
    uint256 constant AUCTION_BATCH_SIZE = 6;

    uint256 constant AUCTION_INITIAL_MAX_PRICE = (256 ether) / 1000;
    uint256 constant AUCTION_PRICE_HALVING_TIME = 2700;
    uint256 constant AUCTION_FREQUENCY = 6 hours;

    uint256 constant GAS_FUND_CAP = 1000 ether;
    uint256 constant GAS_REFUND_MIN_GAS_PRICE = 8 gwei;
    uint256 constant GAS_REFUND_PRICE_DOUBLING_TIME = 1800;
    uint256 constant GAS_REFUND_AUCTION_FREQUENCY = 3 hours;

    address public owner;
    address public blockheadsContractAddress;
    address public blockballContractAddress;
    address public blockmintingContractAddress;
    address public blockletsContractAddress;
    address public blocktrophiesContractAddress;
    address public utilityFormattingContractAddress;

    bool public finalized;

    mapping (uint256 => uint256) public tokenData;
    bytes32 public tokenDataMerkleRoot;

    mapping(uint256 => uint256) countAuctionsFromCluster;
    uint256 public auctionId;
    uint256 public currentAuctionsFirstId;
    uint256 public currentAuctionsStartTime;
    uint256 public auctionMaxPrice;
    uint256 public auctionMaxSoldPrice;

    uint256 public gasFund;
    uint256 public gasFundTotal;
    uint256 public developmentFund;

    uint256 random;

    event Auction(uint256 indexed auctionId, uint256 startTime, uint256 repeatTime, uint256 maxPrice, uint256 minPrice, uint256 token0, uint256 token1, uint256 token2, uint256 token3, uint256 token4, uint256 token5);
    event Mint(uint256 indexed tokenId, address indexed userAddress);


    constructor(address blockheads) {
        owner = msg.sender;
        blockheadsContractAddress = blockheads;
        random = uint256(keccak256(abi.encodePacked(random, "Blockheads", blockhash(block.number - 1), block.timestamp)));
        auctionMaxPrice = AUCTION_INITIAL_MAX_PRICE;
    }

    function setOwner(address newOwner) external {
        require(msg.sender == owner);
        owner = newOwner;
    }

    function withdrawFromDevelopmentFund(uint256 amount) external {
        require(msg.sender == owner);

        if (BlockheadsForAuction(blockheadsContractAddress).finalized()) {
            require(amount <= developmentFund);
            developmentFund -= amount;
        }

        payable(owner).transfer(amount);
    }

    function setContractAddresses(address blockball, address blockminting, address blocklets, address blocktrophies, address utilityFormatting) external {
        require(msg.sender == blockheadsContractAddress);
        blockballContractAddress = blockball;
        blockmintingContractAddress = blockminting;
        blockletsContractAddress  = blocklets;
        blocktrophiesContractAddress = blocktrophies;
        utilityFormattingContractAddress = utilityFormatting;
    }

    function _getRandom() internal returns (uint256 result) {
        random = uint256(keccak256(abi.encodePacked(random, "Block", blockhash(block.number - 1), block.timestamp)));
        result = random;
    }

    function verifyTokenData(uint256 _tokenId, uint256 _tokenData, bytes32[] calldata merkleNodes) public pure returns (bytes32) {
        require(_tokenData > 0);
        uint256 layer = 0;
        uint256 layerSize = BLOCKHEADS_COUNT;
        uint256 layerPosition = _tokenId;
        bytes32 node = bytes32(_tokenData);
        while (layerSize > 1) {
            bytes32 left;
            bytes32 right;
            if (layerPosition % 2 == 0) {
                left = node;
                right = merkleNodes[layer];
            } else {
                left = merkleNodes[layer];
                right = node;
            }
            node = keccak256(abi.encodePacked(left, right));
            layer += 1;
            layerSize = (layerSize + 1) / 2;
            layerPosition = layerPosition / 2;
        }
        return node;
    }

    function finalize(bytes32[] calldata _data) public {
        require(msg.sender == owner);
        require(finalized == false);

        require(_data.length == BLOCKHEADS_COUNT);
        bytes32[] memory merkleTreeLayer = new bytes32[]((BLOCKHEADS_COUNT + 1) / 2);
        uint256 layerLength = (BLOCKHEADS_COUNT + 1) / 2;
        for (uint256 i = 0; i < layerLength; i++) {
            bytes32 left = bytes32(_data[2 * i]);
            bytes32 right;
            if (2 * i + 1 < BLOCKHEADS_COUNT) {
                right = bytes32(_data[2 * i + 1]);
            } else {
                right = bytes32(0);
            }
            bytes32 parent = keccak256(abi.encodePacked(left, right));
            merkleTreeLayer[i] = parent;
        }
        while (layerLength > 1) {
            uint256 previousLayerLength = layerLength;
            layerLength = (layerLength + 1) / 2;
            for (uint256 i = 0; i < layerLength; i++) {
                bytes32 left = merkleTreeLayer[2 * i];
                bytes32 right;
                if (2 * i + 1 < previousLayerLength) {
                    right = merkleTreeLayer[2 * i + 1];
                } else {
                    right = bytes32(0);
                }
                bytes32 parent = keccak256(abi.encodePacked(left, right));
                merkleTreeLayer[i] = parent;
            }
        }
        tokenDataMerkleRoot = merkleTreeLayer[0];

        finalized = true;

        _setupAuctions();
    }

    function _setupAuctions() internal {
        uint256 firstId;
        if ((auctionId + 1) * AUCTION_BATCH_SIZE <= BLOCKHEADS_COUNT) {
            firstId = (_getRandom() % (BLOCKHEADS_COUNT / AUCTION_BATCH_SIZE)) * AUCTION_BATCH_SIZE;

            // Searching for tokens available for sale

            // Searching for available cluster
            uint256 clusterId = firstId / AUCTION_CLUSTER_SIZE;
            while (countAuctionsFromCluster[clusterId] == AUCTION_CLUSTER_SIZE) {
                clusterId += 1;
                clusterId %= AUCTION_CLUSTER_COUNT;
                firstId = clusterId * AUCTION_CLUSTER_SIZE;
            }
            bool owned = false;
            
            // Searching for available batch
            try BlockheadsForAuction(blockheadsContractAddress).ownerOf(firstId) returns (address) {
                owned = true;
            } catch {}

            while (owned) {
                firstId += AUCTION_BATCH_SIZE;
                if (firstId % AUCTION_CLUSTER_SIZE == 0) { // Hopped into new cluster, go back
                    firstId -= AUCTION_CLUSTER_SIZE;
                }
                owned = false;
                
                try BlockheadsForAuction(blockheadsContractAddress).ownerOf(firstId) returns (address) {
                    owned = true;
                } catch {}
            }
        } else {
            currentAuctionsFirstId = 0;
            currentAuctionsStartTime = 0;
            return;
        }
        
        currentAuctionsFirstId = firstId;

        currentAuctionsStartTime = block.timestamp; // Auctions run continuously

        if (4 * auctionMaxSoldPrice > auctionMaxPrice) {
            auctionMaxPrice = 4 * auctionMaxSoldPrice;
        }

        emit Auction(auctionId, currentAuctionsStartTime, AUCTION_FREQUENCY, auctionMaxPrice, auctionMaxPrice / 19,
            firstId, firstId + 1, firstId + 2, firstId + 3, firstId + 4, firstId + 5);

        auctionId += 1;
    }

    function getAuctionPrice() public view returns (uint256 price) {
        if ((block.timestamp <= currentAuctionsStartTime) || (currentAuctionsStartTime == 0)) {
            return 0;
        }
        
        uint256 elapsedTime = block.timestamp - currentAuctionsStartTime;
        elapsedTime %= AUCTION_FREQUENCY;

        // Piecewise linear approximation of an exponential function
        price = auctionMaxPrice >> (elapsedTime / AUCTION_PRICE_HALVING_TIME);
        price -= price * (elapsedTime % AUCTION_PRICE_HALVING_TIME) / AUCTION_PRICE_HALVING_TIME / 2;
    }

    function getGasRefundPrice() public view returns (uint256 price) {
        uint256 elapsedTime = block.timestamp % GAS_REFUND_AUCTION_FREQUENCY;

        price = GAS_REFUND_MIN_GAS_PRICE << (elapsedTime / GAS_REFUND_PRICE_DOUBLING_TIME);
        price += price * (elapsedTime % GAS_REFUND_PRICE_DOUBLING_TIME) / GAS_REFUND_PRICE_DOUBLING_TIME;
    }

    function requestGasRefund(uint256 _gasUsed) external returns (uint256 price) {
        require(msg.sender == blockballContractAddress);

        price = getGasRefundPrice();

        uint256 refund = _gasUsed * price;
        payable(msg.sender).transfer(refund);
    }

    function mint(uint256 _tokenId, uint256 _tokenData, bytes32[] calldata merkleNodes) external payable {
        uint256 price = getAuctionPrice();
        require(price > 0, "Closed");

        bytes32 verifiedRoot = verifyTokenData(_tokenId, _tokenData, merkleNodes);
        require(tokenDataMerkleRoot == verifiedRoot);

        require(_tokenId >= currentAuctionsFirstId, "Id");
        require(_tokenId < currentAuctionsFirstId + AUCTION_BATCH_SIZE, "Id");
        require(_tokenId < BLOCKHEADS_COUNT, "Id");

        bool owned = false;
        try BlockheadsForAuction(blockheadsContractAddress).ownerOf(_tokenId) returns (address) {
            owned = true;
        } catch {}
        require(!owned, "Sold");

        require(msg.value >= price, "Price");

        BlockheadsForAuction(blockheadsContractAddress).mintBlockhead(msg.sender, _tokenId, _tokenData);
        emit Mint(_tokenId, msg.sender);
        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }

        if (gasFundTotal < GAS_FUND_CAP) {
            gasFundTotal += price;
            gasFund += price;
            if (gasFundTotal > GAS_FUND_CAP) {
                uint256 gasFundOverflow = gasFundTotal - GAS_FUND_CAP;
                developmentFund += gasFundOverflow;
                gasFund -= gasFundOverflow; // gasFund >= price >= gasFundOverflow
                gasFundTotal = GAS_FUND_CAP;
            }
        } else {
            developmentFund += price;
        }

        if (price > auctionMaxSoldPrice) {
            auctionMaxSoldPrice = price;
        }

        countAuctionsFromCluster[_tokenId / AUCTION_CLUSTER_SIZE] += 1;
        if ((countAuctionsFromCluster[_tokenId / AUCTION_CLUSTER_SIZE] % AUCTION_BATCH_SIZE) == 0) {
            _setupAuctions();
        }
    }
}