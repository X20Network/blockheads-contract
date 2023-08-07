// SPDX-License-Identifier: All Rights Reserved
// Copyright 2023 Blockheads.network. All Rights Reserved.
pragma solidity >=0.8.0;

import "./token/ERC721/extensions/ERC721Enumerable.sol";
import "./utils/Strings.sol";

abstract contract UtilityFormattingForBlockheads {
    function formatURI(uint256 tokenId, uint256 tokenData) public view virtual returns (string memory);
    function blockheadsSVG(uint256 _tokenId) public view virtual returns (string memory svgStringFullString, uint256 svgStringLength, string[8] memory _traitStrings);
}

abstract contract ContractReferencesForBlockheads {
    function setContractAddresses(address blockball, address blockminting, address blocklets, address blocktrophies, address utilityFormatting) external virtual;
}

contract Blockheads is ERC721Enumerable {

    bool public finalized;
    
    mapping (uint256 => uint256) public tokenData;
    bytes32 public tokenDataMerkleRoot;
    bool public winBarEnabled;

    address public owner;
    address public blockballContractAddress;
    address public blockmintingContractAddress;
    address public blockletsContractAddress;
    address public blocktrophiesContractAddress;
    address public utilityFormattingContractAddress;

    mapping (uint256 => address) public realOwnerOf;

    uint256 constant BLOCKHEADS_COUNT = 1992;

    event Auction(uint256 indexed auctionId, uint256 startTime, uint256 repeatTime, uint256 maxPrice, uint256 minPrice, uint256 token0, uint256 token1, uint256 token2, uint256 token3, uint256 token4, uint256 token5);
    event Mint(uint256 indexed tokenId, address indexed userAddress);
    event BlockheadData(uint256 indexed tokenId, uint256 tokenData);
    event Whitepaper(string title, string text);


    constructor() ERC721("Blockheads", "BLOCKHEAD") {
        owner = msg.sender;
        finalized = false;
    }

    function setOwner(address newOwner) external {
        require(msg.sender == owner);
        owner = newOwner;
    }

    function updateData(uint256 blockId, uint256 newData) external {
        require(msg.sender == blockballContractAddress);
        tokenData[blockId] = newData;
    }

    function setContractAddresses(address blockball, address blockminting, address blocklets, address blocktrophies, address utilityFormatting) external {
        require(msg.sender == owner);
        require(finalized == false);

        if (blockball != address(0)) {
            blockballContractAddress = blockball;
        }
        if (blockminting != address(0)) {
            blockmintingContractAddress = blockminting;
        }
        if (blocklets != address(0)) {
            blockletsContractAddress  = blocklets;
        }
        if (blocktrophies != address(0)) {
            blocktrophiesContractAddress = blocktrophies;
        }
        if (utilityFormatting != address(0)) {
            utilityFormattingContractAddress = utilityFormatting;
        }
        
        if (blockballContractAddress != address(0)) {
            ContractReferencesForBlockheads(blockballContractAddress).setContractAddresses(blockballContractAddress, blockmintingContractAddress, blockletsContractAddress, blocktrophiesContractAddress, utilityFormattingContractAddress);
        }
        if (blockmintingContractAddress != address(0)) {
            ContractReferencesForBlockheads(blockmintingContractAddress).setContractAddresses(blockballContractAddress, blockmintingContractAddress, blockletsContractAddress, blocktrophiesContractAddress, utilityFormattingContractAddress);
        }
        if (blockletsContractAddress != address(0)) {
            ContractReferencesForBlockheads(blockletsContractAddress).setContractAddresses(blockballContractAddress, blockmintingContractAddress, blockletsContractAddress, blocktrophiesContractAddress, utilityFormattingContractAddress);
        }
        if (blocktrophiesContractAddress != address(0)) {
            ContractReferencesForBlockheads(blocktrophiesContractAddress).setContractAddresses(blockballContractAddress, blockmintingContractAddress, blockletsContractAddress, blocktrophiesContractAddress, utilityFormattingContractAddress);
        }
        if (utilityFormattingContractAddress != address(0)) {
            ContractReferencesForBlockheads(utilityFormattingContractAddress).setContractAddresses(blockballContractAddress, blockmintingContractAddress, blockletsContractAddress, blocktrophiesContractAddress, utilityFormattingContractAddress);
        }
    }

    function finalize() external {
        require(msg.sender == owner);
        finalized = true;
    }

    function addWhitepaper(bool log, string calldata title, string calldata text) external {
        require(msg.sender == owner);
        if (log) {
            emit Whitepaper(title, text);
        }
    }

    function mintBlockhead(address userAddress, uint256 tokenId, uint256 _tokenData) public {
        require(msg.sender == blockmintingContractAddress);
        tokenData[tokenId] = _tokenData;
        _mint(userAddress, tokenId);
    }

    function mintPrizes(address gold, address silver, address bronze) external {
        require(msg.sender == blockballContractAddress);
        tokenData[1992] = 0x0000000000000000000000000000000000000000000000000000000000000000;
        tokenData[1993] = 0x0000000000000000000000000000000100000000000000000000000000000000;
        tokenData[1994] = 0x0000000000000000000000000000000200000000000000000000000000000000;
        _mint(gold, 1992);
        _mint(silver, 1993);
        _mint(bronze, 1994);
    }

    function freezeMyBlockhead(address userAddress, uint256 tokenId) public returns (bool) {
        require(msg.sender == blockballContractAddress);
        realOwnerOf[tokenId] = userAddress;
        _transfer(userAddress, address(this), tokenId);
        return true;
    }

    function unfreezeMyBlockhead(address userAddress, uint256 tokenId) public returns (bool) {
        require(msg.sender == blockballContractAddress);
        _transfer(address(this), realOwnerOf[tokenId], tokenId);
        realOwnerOf[tokenId] = address(0);
        return true;
    }

    function burnMyBlockhead(address userAddress, uint256 tokenId) public returns (bool) {
        require(msg.sender == blockballContractAddress);
        _burn(tokenId);
        return true;
    }

    struct ExtensibleString {
        uint256 length;
        string fullString;
    }

    function enableWinBar(bool enabled) external {
        require(msg.sender == owner);
        winBarEnabled = enabled;
    }

    function hideWinBar(uint256 tokenId, bool hideBar) external {
        require(winBarEnabled);
        require(msg.sender == this.ownerOf(tokenId));
        if (hideBar) {
            tokenData[tokenId] |= uint256(1) << (128 + 40 + 40);
        } else {
            tokenData[tokenId] &= ~(uint256(1) << (128 + 40 + 40));
        }
    }

    function tokenSVG(uint256 _tokenId) public view returns (string memory svgStringFullString, uint256 svgStringLength, string[8] memory _traitStrings) {
        return UtilityFormattingForBlockheads(utilityFormattingContractAddress).blockheadsSVG(_tokenId);
    }

    // Returns the tokenURI
    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        return UtilityFormattingForBlockheads(utilityFormattingContractAddress).formatURI(_tokenId, tokenData[_tokenId]);
    }
}
