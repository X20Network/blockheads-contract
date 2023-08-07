// SPDX-License-Identifier: All Rights Reserved
// Copyright 2023 Blockheads.network. All Rights Reserved.
pragma solidity >=0.8.0;

import "./token/ERC721/extensions/ERC721Enumerable.sol";
import "./utils/Strings.sol";

abstract contract UtilityFormattingForBlocklets {
    function formatURI(uint256 tokenId, uint256 tokenData) public view virtual returns (string memory);
}

contract Blocklets is ERC721Enumerable {

    bool finalized;
    uint256 tokensPreset;
    mapping (uint256 => uint256) public tokenData;
    uint256 tokenCount;

    address owner;
    address public blockheadsContractAddress;
    address public blockballContractAddress;
    address public blockmintingContractAddress;
    address public blockletsContractAddress;
    address public blocktrophiesContractAddress;
    address public utilityFormattingContractAddress;

    uint256 constant PALETTE_WHITE  = 0xE0E8EE;
    uint256 constant PALETTE_GREY_D = 0xC0D4DD;
    uint256 constant PALETTE_GREY_B = 0xA0B4BB;
    uint256 constant PALETTE_GREY_A = 0x90A4AA;
    uint256 constant PALETTE_GREY_8 = 0x708288;
    uint256 constant PALETTE_GREY_7 = 0x607277;
    uint256 constant PALETTE_GREY_5 = 0x445255;
    uint256 constant PALETTE_GREY_4 = 0x334044;
    uint256 constant PALETTE_GREY_3 = 0x2A2D33;
    uint256 constant PALETTE_GREY_2 = 0x1A1D22;
    uint256 constant PALETTE_BLACK  = 0x0A0D11;

    uint256 constant PALETTE_EYE            = 0x00C0FF;
    uint256 constant PALETTE_EYE_DARK       = 0x282858;
    uint256 constant PALETTE_EYE_LIGHT      = 0x60D0FF;
    uint256 constant PALETTE_EYE_RED        = 0xEE0000;

    uint256 constant PALETTE_BABY_BLUE      = 0x80C0F0;
    uint256 constant PALETTE_BABY_BLUE_D    = 0x70AAD8;
    uint256 constant PALETTE_BABY_BLUE_C    = 0x6098C0;
    uint256 constant PALETTE_BABY_BLUE_DARK = 0x5080AA;
    uint256 constant PALETTE_BABY_BLUE_9    = 0x406898;
    uint256 constant PALETTE_PINK           = 0xF8C8F8;
    uint256 constant PALETTE_PINK_D         = 0xDDB0E0;
    uint256 constant PALETTE_PINK_B         = 0xBB99CC;
    uint256 constant PALETTE_PINK_DARK      = 0x9D7DB4;
    uint256 constant PALETTE_PINK_8         = 0x8066A0;

    uint256 constant PALETTE_GOLD_FD = 0xFFE070;
    uint256 constant PALETTE_GOLD_FC = 0xFFD040;
    uint256 constant PALETTE_GOLD_FB = 0xFFC000;
    uint256 constant PALETTE_GOLD_C  = 0xC09930;
    uint256 constant PALETTE_GOLD_A  = 0xAA8000;
    
    uint256 constant PALETTE_BRONZE = 0xFFA077;

    uint256 constant PALETTE_PURPLE_DARK  = 0x301050;
    uint256 constant PALETTE_PURPLE_MID   = 0x603860;
    uint256 constant PALETTE_PURPLE_LIGHT = 0xAA70B0;

    uint256 constant PALETTE_GREEN_LIGHT = 0x50D050;
    uint256 constant PALETTE_GREEN_DARK  = 0x308030;

    uint256 constant PALETTE_RED = 0xB02020;

    uint256 constant PALETTE_BROWN_LIGHT = 0xCC9966;
    uint256 constant PALETTE_BROWN_DARK  = 0x996633;
    
    uint256 constant PALETTE_OSCILLOSCOPE_FRAME  = 0xB0B088;
    uint256 constant PALETTE_OSCILLOSCOPE_SIGNAL = 0x99FFFF;
    constructor(address blockheads) ERC721("Blocklets", "BLOCKLET") {
        owner = msg.sender;
        blockheadsContractAddress = blockheads;
        
        finalized = false;
        tokensPreset = 0;

        tokenCount = 1 << 16;
    }

    function setOwner(address newOwner) external {
        require(msg.sender == owner);
        owner = newOwner;
    }

    function setContractAddresses(address blockball, address blockminting, address blocklets, address blocktrophies, address utilityFormatting) external {
        require(msg.sender == blockheadsContractAddress);
        blockballContractAddress = blockball;
        blockmintingContractAddress = blockminting;
        blockletsContractAddress  = blocklets;
        blocktrophiesContractAddress = blocktrophies;
        utilityFormattingContractAddress = utilityFormatting;
    }

    function updateData(uint256 blockId, uint256 newData) external {
        require(msg.sender == blockballContractAddress);
        tokenData[blockId] = newData;
    }

    function presetTokens(uint256[] calldata data) public {
        require(msg.sender == owner);
        require(finalized == false);
        for (uint256 i = 0; i < data.length; i++) {
            tokenData[tokensPreset + i] = data[i];
        }
        tokensPreset += data.length;
    }

    function awardBlocklet(address userAddress, uint256 data) public returns (uint256 blockletId)  {
        require(msg.sender == blockballContractAddress);
        tokenData[tokenCount] = data;
        _mint(userAddress, tokenCount);
        blockletId = tokenCount;
        tokenCount++;
    }

    struct ExtensibleString {
        uint256 length;
        string fullString;
    }


    // Appends a string to another in a gas efficient manner
    function _appendString(ExtensibleString memory originalString, string memory appendedString) internal view returns (uint256 newLength) {
        uint256 appendedLength = bytes(appendedString).length;
        uint256 originalLength = originalString.length;
        newLength = originalLength + appendedLength;
        bytes memory bytesOriginal = bytes(originalString.fullString);
        bytes memory bytesAppended = bytes(appendedString);
        for (uint256 i = originalLength; i < newLength; i++) {
            bytesOriginal[i] = bytesAppended[i - originalLength];
        }
        originalString.length += appendedLength;
    }

    uint256 constant M_ONE = 100000;
    uint256 constant M_COS = 86603;
    uint256 constant M_SIN = 50000;

    function _addPaletteColor(uint256[128] memory _palette, uint256 _paletteLength, uint256 _color) internal pure returns (uint256) {
        _palette[_paletteLength] = _color;
        return _paletteLength + 1;
    }

    function _colorHexToString(uint256 colorValue) internal pure returns (string memory color) {
        color = "000000";
        string memory colorHex = Strings.toHexString(colorValue, 3);
        bytes memory bytesColorHex = bytes(colorHex);
        bytes memory bytesColor = bytes(color);
        for (uint256 k = 0; k < 6; k++) {
            bytesColor[k] = bytesColorHex[k + 2];
        }
    }

    // Append a voxel to an SVG string
    function _appendVoxel(ExtensibleString memory voxelString, uint256 x, uint256 y, uint256 z, uint256 c, uint256 id, string memory _tokenHash) internal view {
     
        
        uint256 i = y * M_COS + (60 - x) * M_COS;
        uint256 j = (60 - z) * M_ONE + y * M_SIN + x * M_SIN;
        
        if (id > 0) {
            _appendString(voxelString, "<g id='");
            _appendString(voxelString, Strings.toString(id));
            _appendString(voxelString, "'>\n");
        }

        _appendString(voxelString, "<use xlink:href='#v-");
        _appendString(voxelString, _tokenHash);
        _appendString(voxelString, "-");
        _appendString(voxelString, Strings.toString(c));
        _appendString(voxelString, "' transform='translate(");
        _appendString(voxelString, Strings.toString(i - 3000000));
        _appendString(voxelString, ',');
        _appendString(voxelString, Strings.toString(j - 3000000));
        _appendString(voxelString, ")'/>\n");

        if (id > 0) {
            _appendString(voxelString, '</g>\n');
        }
    }

    function tokenSVG(uint256 _tokenId) public view returns (string memory svgStringFullString, uint256 svgStringLength, string[8] memory _traitStrings) {
        ExtensibleString memory svgString;
        bytes memory svgBytes = new bytes(10000+188*400);
        svgString.length = 0;
        svgString.fullString = string(svgBytes);

        _appendString(svgString, "<svg width='600' height='600' viewBox='4696180 5550000 3200000 3200000' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'>\n"); 

        string memory tokenHash = Strings.toHexString(_tokenId, 8);

        // Face
        uint256[128] memory palette;
        uint256 paletteLength = 0;
        paletteLength = _addPaletteColor(palette, paletteLength, 0xFFFFFF); // [0] should be ignored for simplicity since it's the empty voxel

        // Single colors
        if (true) {
            uint256 tokenVisuals = tokenData[_tokenId] >> 128;
            uint256 blockColor = (tokenVisuals >> (8 * 0)) & 0xff; // (CHANGED)
            uint256 primaryColor = blockColor / 5;
            uint256 secondaryColor = blockColor % 5;
            bool darkEyes = false;
            if (primaryColor == 0) {
                // Blue
                _traitStrings[0] = "Blue";
                paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_BABY_BLUE); // [1]
                darkEyes = true;
            } else {
                if (primaryColor == 1) {
                    // Pink
                    _traitStrings[0] = "Pink";
                    paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_PINK); // [1]
                } else {
                    if (primaryColor == 2) {
                        // Dark
                        _traitStrings[0] = "Dark";
                        paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GREY_4);
                    } else {
                        // Grey
                        _traitStrings[0] = "Grey";
                        paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GREY_D);
                    }
                }
            }
            if (secondaryColor == 0) {
                // -blue
                _traitStrings[1] = "Blue";
                paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_BABY_BLUE_DARK); // [1]
            } else {
                if (secondaryColor == 1) {
                    // -pink
                    _traitStrings[1] = "Pink";
                    paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_PINK_DARK); // [1]
                } else {
                    if (secondaryColor == 2) {
                        // -dark
                        _traitStrings[1] = "Dark";
                        paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GREY_2);
                    } else {
                        // -grey
                        _traitStrings[1] = "Grey";
                        paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GREY_B);
                    }
                }
            }
            if (darkEyes) {
                paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_EYE_DARK); // [3] Eyes (dark)
            } else {
                paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_EYE); // [3] Eyes (blue)
            }
        }



        
        for (uint256 i = 33; i < 39; i++) {
            for (uint256 j = 33; j < 39; j++) {
                _appendVoxel(svgString, i, 39, j, 2, 0, tokenHash); // Inner face
            }
        }
        for (uint256 i = 32; i < 40; i++) {
            _appendVoxel(svgString, 32, 39, i, 1, 0, tokenHash); // Right edge
            _appendVoxel(svgString, i, 39, 32, 1, 0, tokenHash); // Bottom edge
        }
        for (uint256 i = 33; i < 39; i++) {
            _appendVoxel(svgString, i, 39, 35, 1, 0, tokenHash); // Nose area
        }
        _appendVoxel(svgString, 33, 39, 33, 1, 0, tokenHash); // Corner
        _appendVoxel(svgString, 38, 39, 33, 1, 0, tokenHash); // Corner


        _appendVoxel(svgString, 37, 39, 37, 1, 0, tokenHash); // Left eyebrow
        _appendVoxel(svgString, 38, 39, 37, 3, 0, tokenHash); // Left eye
        _appendVoxel(svgString, 38, 39, 38, 1, 0, tokenHash); // Left eyebrow

        _appendVoxel(svgString, 33, 39, 37, 3, 0, tokenHash); // Right
        _appendVoxel(svgString, 34, 39, 37, 1, 0, tokenHash); // Right eyebrow
        _appendVoxel(svgString, 33, 39, 38, 1, 0, tokenHash); // Right eyebrow

        for (uint256 i = 32; i < 40; i++) {
            _appendVoxel(svgString, i, 39, 39, 1, 0, tokenHash); // Top edge
            _appendVoxel(svgString, 39, 39, i, 1, 0, tokenHash); // Left edge
        }
        
        for (uint256 i = 32; i < 40; i++) {
            for (uint256 j = 32; j < 40; j++) {
                _appendVoxel(svgString, 39, i, j, 1, 0, tokenHash); // Left side
                _appendVoxel(svgString, i, j, 39, 1, 0, tokenHash); // Top side
            }
        }

        // Palette
        _appendString(svgString, '<defs>\n');
        for (uint256 i = 1; i < paletteLength; i++) {
            uint256 color = palette[i];
            uint256 colorBright = 0;
            uint256 colorDark = 0;
            if (true) {
                uint256 colorR = (color >> 16) & 0xFF;
                uint256 colorG = (color >> 8) & 0xFF;
                uint256 colorB = color & 0xFF;
                if (colorR < 215) {
                    colorBright += ((colorR / 5) * 6) << 16;
                } else {
                    colorBright += 0xFF << 16;
                }
                if (colorG < 215) {
                    colorBright += ((colorG / 5) * 6) << 8;
                } else {
                    colorBright += 0xFF << 8;
                }
                if (colorB < 215) {
                    colorBright += (colorB / 5) * 6;
                } else {
                    colorBright += 0xFF;
                }
                colorDark += ((colorR / 5) * 4) << 16;
                colorDark += ((colorG / 5) * 4) << 8;
                colorDark += (colorB / 5) * 4;
            }

            _appendString(svgString, "<g id='v-");
            _appendString(svgString, tokenHash);
            _appendString(svgString, "-");
            _appendString(svgString, Strings.toString(i));
            _appendString(svgString, "'>\n");

            _appendString(svgString, "<polygon points='4100000,4100000 4100000,4200000 4013397,4150000 4013397,4050000' fill='#");
            _appendString(svgString, _colorHexToString(colorDark));
            _appendString(svgString, "' id='r");
            _appendString(svgString, Strings.toString(i));
            _appendString(svgString, "L'/>\n");

            _appendString(svgString, "<polygon points='4100000,4100000 4100000,4200000 4186602,4150000 4186602,4050000' fill='#");
            _appendString(svgString, _colorHexToString(color));
            _appendString(svgString, "' id='r");
            _appendString(svgString, Strings.toString(i));
            _appendString(svgString, "R'/>\n");

            _appendString(svgString, "<polygon points='4100000,4100000 4013397,4050000 4100000,4000000 4186602,4050000' fill='#");
            _appendString(svgString, _colorHexToString(colorBright));
            _appendString(svgString, "' id='r");
            _appendString(svgString, Strings.toString(i));
            _appendString(svgString, "T'/>\n");
            _appendString(svgString, "</g>\n");
        }
        _appendString(svgString, '</defs>\n');

        _appendString(svgString, '</svg>\n');

        svgStringFullString = svgString.fullString;
        svgStringLength = svgString.length;
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        return UtilityFormattingForBlocklets(utilityFormattingContractAddress).formatURI(_tokenId, tokenData[_tokenId]);
    }
}
