// SPDX-License-Identifier: All Rights Reserved
// Copyright 2023 Blockheads.network. All Rights Reserved.
pragma solidity >=0.8.0;

import "./utils/Strings.sol";
    
struct ExtensibleString {
    uint256 length;
    string fullString;
}


abstract contract BlockheadsForUtilityFormatting {
    function tokenData(uint256 _tokenId) public view virtual returns (uint256);
}

abstract contract Blockheads3dForUtilityFormatting {
    function getExtraLength() public view virtual returns (uint256);
    function getFieldName() public view virtual returns (string memory);
    function getPrefix() public view virtual returns (string memory);
    function getBase64() public view virtual returns (bool);
    function token3d(uint256 tokenId) public view virtual returns (string memory);
}

contract UtilityFormatting {
    string internal constant TABLE_ENCODE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    bytes  internal constant TABLE_DECODE = hex"0000000000000000000000000000000000000000000000000000000000000000"
                                            hex"00000000000000000000003e0000003f3435363738393a3b3c3d000000000000"
                                            hex"00000102030405060708090a0b0c0d0e0f101112131415161718190000000000"
                                            hex"001a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132330000000000";
    
    uint8 constant BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_TYPE_0_TITANIUM      = 12;
    uint8 constant BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_TYPE_1_SILICON       = 24;
    uint8 constant BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_TYPE_2_ALUMINIUM     = 36;
    uint8 constant BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_TYPE_3_WIREFRAME     = 37;
    uint8 constant BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_TYPE_4_OSCILLOSCOPE  = 43;
    uint8 constant BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_TYPE_5_STEAMPUNK     = 51;
    uint8 constant BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_TYPE_6_ALIEN         = 59;
    uint8 constant BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_TYPE_7_PSYCHEDELIC   = 67;
    uint8 constant BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_TYPE_8_ZOMBIE        = 75;
    uint8 constant BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_TYPE_9_CAMOUFLAGE    = 87;
    uint8 constant BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_TYPE_10_GOLD         = 99;
    uint8 constant BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_TYPE_11_BLUE_GRAD    = 115;
    uint8 constant BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_TYPE_12_PINK_GRAD    = 131;


    uint8 constant BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_SIDE_0_CIRCUIT_BOARD = 6;
    uint8 constant BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_SIDE_1_HEADPHONES    = 38;


    uint8 constant BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_TOP_0_ELECTRONIC     = 6;
    uint8 constant BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_TOP_1_HOODIE_GREY    = 18;
    uint8 constant BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_TOP_2_HOODIE_BLUE    = 30;
    uint8 constant BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_TOP_3_HOODIE_PINK    = 42;
    uint8 constant BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_TOP_4_MOHAWK         = 74;
    uint8 constant BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_TOP_5_HAIR           = 106;


    uint8 constant BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_EYES_0_RAINBOW       = 6;
    uint8 constant BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_EYES_1_VISOR         = 22;
    uint8 constant BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_EYES_2_3D_GLASSES    = 34;
    uint8 constant BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_EYES_3_SUNGLASSES    = 66;
    uint8 constant BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_EYES_4_CYCLOPS       = 74;
    uint8 constant BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_EYES_5_CYCLOPS_VISOR = 82;
    uint8 constant BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_EYES_6_RED_EYE       = 130;


    uint8 constant BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_MOUTH_0_GAS_MASK     = 4;
    uint8 constant BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_MOUTH_1_MASK         = 8;
    uint8 constant BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_MOUTH_2_TEETH_CIG    = 12;
    uint8 constant BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_MOUTH_3_TEETH        = 44;
    uint8 constant BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_MOUTH_4_STRAIGHT_CIG = 50;
    uint8 constant BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_MOUTH_5_STRAIGHT     = 98;
    uint8 constant BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_MOUTH_6_SMILE_CIG    = 106;

    uint256 constant WIN_COUNT_THRESHOLD_0 = 1;
    uint256 constant WIN_COUNT_THRESHOLD_1 = 2;
    uint256 constant WIN_COUNT_THRESHOLD_2 = 5;
    uint256 constant WIN_COUNT_THRESHOLD_3 = 10;
    uint256 constant WIN_COUNT_THRESHOLD_4 = 20;
    uint256 constant WIN_COUNT_THRESHOLD_5 = 50;
    uint256 constant WIN_COUNT_THRESHOLD_6 = 100;

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
    


    address owner;
    address public blockheadsContractAddress;
    address public blockballContractAddress;
    address public blockmintingContractAddress;
    address public blockletsContractAddress;
    address public blocktrophiesContractAddress;
    address public utilityFormattingContractAddress;

    address public blockheads3dContractAddress;
    bool public blockheads3dContractAddressFinalized;
    constructor(address blockheads) {
        owner = msg.sender;
        blockheadsContractAddress = blockheads;
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

    function setBlockheads3dContractAddress(address blockheads3d) external {
        require(msg.sender == owner);
        require (blockheads3dContractAddressFinalized == false);
        blockheads3dContractAddress = blockheads3d;
    }

    function finalizeBlockheads3dContractAddress() external {
        require(msg.sender == owner);
        blockheads3dContractAddressFinalized = true;
    }

    function base64encode(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return '';

        string memory table = TABLE_ENCODE;
        uint256 encodedLen = 4 * ((data.length + 2) / 3);
        string memory result = new string(encodedLen + 32);

        assembly {
            mstore(result, encodedLen)
            let tablePtr := add(table, 1)
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))
            let resultPtr := add(result, 32)
            for {} lt(dataPtr, endPtr) {}
            {
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr( 6, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(        input,  0x3F))))
                resultPtr := add(resultPtr, 1)
            }
            switch mod(mload(data), 3)
            case 1 { mstore(sub(resultPtr, 2), shl(240, 0x3d3d)) }
            case 2 { mstore(sub(resultPtr, 1), shl(248, 0x3d)) }
        }

        return result;
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

    // Appends a voxel to an SVG string
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

        function _drawTopSlice(uint256 startX, uint256 startY, uint256 startZ, uint256 sizeX, uint256 sizeZ, uint256 paletteBitCount, uint256 paletteOffset, uint256 slice, uint256[4096] memory voxelData) internal pure {
        require(sizeX * sizeZ * paletteBitCount <= 256);
        require(startX + sizeX - 1 < 16);
        require(startY < 16);
        require(startZ + sizeZ - 1 < 16);

        for (uint256 k = 0; k < sizeZ; k++) {
            for (uint256 i = 0; i < sizeX; i++) {
                uint256 voxelIndex = (k + startZ) * 256 + startY * 16 + (i + startX);

                uint256 sliceIndex = (sizeZ - k - 1) * sizeX + (sizeX - i - 1);

                uint256 voxelValue = slice >> (sliceIndex * paletteBitCount);
                voxelValue &= (0x1 << paletteBitCount) - 1;

                if (((voxelValue > 1) || ((voxelValue == 1) && (paletteBitCount == 1))) || (paletteBitCount == 0)) {
                    // 2+ bits: 0 1 fixed, 2+ receive offset
                    // 1 bit: 0 fixed, 1+ receive offset
                    // 0 bits: all zeros receive offset
                    voxelValue += paletteOffset;
                }
                voxelData[voxelIndex] = voxelValue;
            }
        }
    }

    function _drawFrontSlice(uint256 startX, uint256 startY, uint256 startZ, uint256 sizeX, uint256 sizeY, uint256 paletteBitCount, uint256 paletteOffset, uint256 slice, uint256[4096] memory voxelData) internal pure {
        require(sizeX * sizeY * paletteBitCount <= 256);
        require(startX + sizeX - 1 < 16);
        require(startY + sizeY - 1 < 16);
        require(startZ < 16);
        for (uint256 j = 0; j < sizeY; j++) {
            for (uint256 i = 0; i < sizeX; i++) {
                uint256 voxelIndex = startZ * 256 + (j + startY) * 16 + (i + startX);
                uint256 sliceIndex = (sizeY - j - 1) * sizeX + (sizeX - i - 1);

                uint256 voxelValue = slice >> (sliceIndex * paletteBitCount);
                voxelValue &= (0x1 << paletteBitCount) - 1;
                if (((voxelValue > 1) || ((voxelValue == 1) && (paletteBitCount == 1))) || (paletteBitCount == 0)) {
                    // 2+ bits: 0 1 fixed, 2+ receive offset
                    // 1 bit: 0 fixed, 1+ receive offset
                    // 0 bits: all zeros receive offset
                    voxelValue += paletteOffset;
                }
                voxelData[voxelIndex] = voxelValue;
            }
        }
    }

    function _drawLeftSlice(uint256 startX, uint256 startY, uint256 startZ, uint256 sizeZ, uint256 sizeY, uint256 paletteBitCount, uint256 paletteOffset, uint256 slice, uint256[4096] memory voxelData) internal pure {
        require(sizeY * sizeZ * paletteBitCount <= 256);
        require(startX < 16);
        require(startY + sizeY - 1 < 16);
        require(startZ + sizeZ - 1 < 16);
        for (uint256 j = 0; j < sizeY; j++) {
            for (uint256 k = 0; k < sizeZ; k++) {
                uint256 voxelIndex = (k + startZ) * 256 + (j + startY) * 16 + startX;
                uint256 sliceIndex = (sizeY - j - 1) * sizeZ + (sizeZ - k - 1);

                uint256 voxelValue = slice >> (sliceIndex * paletteBitCount);
                voxelValue &= (0x1 << paletteBitCount) - 1;
                if (((voxelValue > 1) || ((voxelValue == 1) && (paletteBitCount == 1))) || (paletteBitCount == 0)) {
                    // 2+ bits: 0 1 fixed, 2+ receive offset
                    // 1 bit: 0 fixed, 1+ receive offset
                    // 0 bits: all zeros receive offset
                    voxelValue += paletteOffset;
                }
                voxelData[voxelIndex] = voxelValue;
            }
        }
    }

    function _appendVoxelData(ExtensibleString memory _voxelString, uint256[4096] memory voxelData, string memory _tokenHash) internal view {
        // Coordinate order:   right->left   backward->forward   downward->upward   color

        for (int256 j = 15; j >= 0; j--) {
            for (int256 k = 0; k <= 15; k++) {
                for (int256 i = 15; i >= 0; i--) {
                    uint256 voxel = voxelData[uint256(k) * 256 + uint256(j) * 16 + uint256(i)];
                    if (voxel > 0) {
                        _appendVoxel(_voxelString, 24 + (16 - uint256(i)), 24 + uint256(k), 24 + (16 - uint256(j)), voxel, 0, _tokenHash);
                    }
                }
            }
        }
    }

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

    function blockheadsSVG(uint256 _tokenId) public view returns (string memory svgStringFullString, uint256 svgStringLength, string[8] memory _traitStrings) {
        ExtensibleString memory svgString;
        bytes memory svgBytes = new bytes(10000+188*400);
        svgString.length = 0;
        svgString.fullString = string(svgBytes);

        _appendString(svgString, "<svg width='600' height='600' viewBox='4436371 5550000 3200000 3200000' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'>\n"); 

        string memory tokenHash = Strings.toHexString(_tokenId, 4);
        uint256[128] memory palette;
        uint256 paletteLength = 0;
        paletteLength = _addPaletteColor(palette, paletteLength, 0xFFFFFF); // [0] Ignored as 0 is used to represent the empty voxel

        uint256[4096] memory voxelData;
        
        uint256 tokenVisuals = BlockheadsForUtilityFormatting(blockheadsContractAddress).tokenData(_tokenId) >> 128;

        // [                                                                                                      -128 BITS: Visuals/Values-                                                                                                      ][ -128 BITS: Strengths/Strategies- ]
        // [ -40 BITS: Placeholder- ][                                                 -48 BITS: Values-                                                ][                                   -40 BITS: Visuals-                                   ]
        //                           [ -8 BITS: winBarHidden- ][ -8 BITS: winPoints- ][ -8 BITS: winCount- ][ -8 BITS: matchCount- ][ -16 BITS: Rarity- ][ -8 BITS: Mouth- ][ -8 BITS: Eyes- ][ -8 BITS: Top- ][ -8 BITS: Side- ][ -8 BITS: Type- ]

        bool noEyes = true;

        // Type
        if (tokenVisuals <= 0x0000000002) {
            _drawFrontSlice(2, 4, 11, 12, 4, 4, 0,  0x111111111111_100000000001_111100001111_113310013311, voxelData); // Front top with eyes
            _drawFrontSlice(2, 8, 11, 12, 4, 4, 0,  0x111100001111_100000000001_100000000001_100000000001, voxelData); // Front mid with eyes
            _drawFrontSlice(2, 12, 11, 12, 4, 4, 0, 0x111111111111_100000000001_110000000011_111111111111, voxelData); // Front bottom
            
            _drawFrontSlice(  2,   4, 0, 12, 12, 0, 1, 0x0, voxelData); // Back
            _drawFrontSlice(2+1, 4+1, 1, 10, 10, 0, 1, 0x0, voxelData); // Back inside

            _drawTopSlice(  2, 4+11, 0+1, 12, 10, 0, 1, 0x0, voxelData); // Bottom
            _drawTopSlice(2+1, 4+10, 0+2, 10,  9, 0, 1, 0x0, voxelData); // Bottom inside
            _drawTopSlice(2+3, 4+10, 0+9,  8,  2, 0, 0, 0x0, voxelData); // Bottom inside hole
            
            _drawTopSlice(2+1, 4+1, 0+2, 10, 9, 0, 1, 0x0, voxelData); // Top inside
            _drawTopSlice(2+2, 4+1, 0+2, 8, 9, 0, 0, 0x0, voxelData); // Top inside hole
            
            _drawTopSlice(2+0, 4+0, 0+1, 12, 10, 0, 1, 0x0, voxelData); // Top inside
            _drawTopSlice(2+1, 4+0, 0+1, 10, 10, 0, 0, 0x0, voxelData); // Top inside hole



            _drawFrontSlice(2, 4+2, 11+1, 12, 3, 4, 0, 0x222222222222_232220023222_023200002320, voxelData); // Shades
            _drawLeftSlice( 2-1, 4+2, 11, 2, 1, 0, 2, 0x0, voxelData); // Shades left side
            _drawLeftSlice(2+12, 4+2, 11, 2, 1, 0, 2, 0x0, voxelData); // Shades right side

            if (tokenVisuals == 0) {
                // Gold award
                _traitStrings[0] = "Gold award";
                _traitStrings[2] = "#1";
                paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GOLD_FD); // [1] Base

                _drawLeftSlice(2, 4+3, 0+4, 3, 5, 4, 0, 0x020_220_020_020_020, voxelData); // Number 1
            } else {
                if (tokenVisuals == 1) {
                    // Silver award
                    _traitStrings[0] = "Silver award";
                    _traitStrings[2] = "#2";
                    paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GREY_D); // [1] Base
                    
                    _drawLeftSlice(2, 4+3, 0+4, 3, 5, 4, 0, 0x222_002_222_200_222, voxelData); // Number 2
                } else {
                    // Bronze award
                    _traitStrings[0] = "Bronze award";
                    _traitStrings[2] = "#3";
                    paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_BRONZE); // [1] Base
                    
                    _drawLeftSlice(2, 4+3, 0+4, 3, 5, 4, 0, 0x222_002_022_002_222, voxelData); // Number 3
                }
            }
            
            _traitStrings[1] = "Normal";
            _traitStrings[3] = "Plain";
            _traitStrings[4] = "Shades";
            _traitStrings[5] = "Smile";
            paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GREY_2); // [2] Secondary (shades)
            paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GREY_7); // [3] Eyes
            
        } else {
            if (true) {
                uint256 blockType = tokenVisuals & 0xff;
                bool colorType = false;

                if (blockType < BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_TYPE_2_ALUMINIUM) {
                    // Metal - Aluminium / Silicon / Titanium
                    if (blockType < BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_TYPE_0_TITANIUM) {
                        // Metal - Titanium
                        _traitStrings[0] = "Titanium";
                        paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_WHITE); // [1] Base
                        paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GREY_B ); // [2] Secondary
                        paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_EYE); // [3] Eyes
                        paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GREY_D); // [4] Frame
                        
                        _drawLeftSlice(2,  4, 0, 11, 4, 4, 0, 0x44444444444_41111111111_41000001111_41110111011, voxelData); // Left top
                        _drawLeftSlice(2,  8, 0, 11, 4, 4, 0, 0x41110111111_41110111011_41110111011_41110111011, voxelData); // Left mid
                        _drawLeftSlice(2, 12, 0, 11, 4, 4, 0, 0x41110111011_41110111011_41111111111_44444444444, voxelData); // Left bottom
                    } else {
                        if (blockType < BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_TYPE_1_SILICON) {
                            // Metal - Silicon
                            _traitStrings[0] = "Silicon";
                            paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GREY_7); // [1] Base
                            paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GREY_B); // [2] Secondary
                            paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_EYE); // [3] Eyes
                            paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GREY_5); // [4] Frame
                            
                            _drawLeftSlice(2,  4, 0, 11, 4, 4, 0, 0x44444444444_41111111111_41100011111_41011101011, voxelData); // Left top
                            _drawLeftSlice(2,  8, 0, 11, 4, 4, 0, 0x41011111111_41100111011_41110011011_41111101011, voxelData); // Left mid
                            _drawLeftSlice(2, 12, 0, 11, 4, 4, 0, 0x41011101011_41100011011_41111111111_44444444444, voxelData); // Left bottom
                        } else {
                            _traitStrings[0] = "Aluminium";
                            paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GREY_B ); // [1] Base
                            paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GREY_A); // [2] Secondary
                            paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_EYE); // [3] Eyes
                            paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GREY_D); // [4] Frame
                            
                            _drawLeftSlice(2,  4, 0, 11, 4, 4, 0, 0x44444444444_41111111111_41100011111_41011101011, voxelData); // Left top
                            _drawLeftSlice(2,  8, 0, 11, 4, 4, 0, 0x41011101011_41011101011_41000001011_41011101011, voxelData); // Left mid
                            _drawLeftSlice(2, 12, 0, 11, 4, 4, 0, 0x41011101011_41011101011_41111111111_44444444444, voxelData); // Left bottom
                        }
                    }
                    _drawLeftSlice(2+1, 4+2, 0+2, 8, 8, 0, 2, 0x0, voxelData); // Left inside

                    _drawFrontSlice(2,  4, 11, 12, 4, 4, 0, 0x444444444444_400000000004_400000000004_400000000004, voxelData); // Front top without eyes
                    _drawFrontSlice(2,  8, 11, 12, 4, 4, 0, 0x400000000004_400000000004_400000000004_411111111114, voxelData); // Front mid without eyes
                    _drawFrontSlice(2, 12, 11, 12, 4, 4, 0, 0x411111111114_400000000004_410000000014_444444444444, voxelData); // Front bottom
                    _drawFrontSlice(2+1, 4+1, 11-1, 10, 10, 0, 2, 0x0, voxelData); // Front inside
                    
                    _drawTopSlice(2+1, 4,   0, 11, 11, 0, 4, 0x0, voxelData); // Top frame
                    _drawTopSlice(2+1, 4, 0+1, 10, 10, 0, 1, 0x0, voxelData); // Top center
                } else {
                    if (blockType < BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_TYPE_3_WIREFRAME) {
                        // Wireframe
                        _traitStrings[0] = "Wireframe";

                        paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_WHITE); // [1] Base
                        paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_WHITE); // [2] Secondary
                        paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_EYE); // [3] Eyes
                        
                        _drawFrontSlice(2, 4, 11, 12, 4, 4, 0,  0x111111111111_100000000001_100000000001_100000000001, voxelData); // Front top without eyes
                        _drawFrontSlice(2, 8, 11, 12, 4, 4, 0,  0x100000000001_100000000001_100000000001_100000000001, voxelData); // Front mid without eyes
                        _drawFrontSlice(2, 12, 11, 12, 4, 4, 0, 0x111111111111_100000000001_110000000011_111111111111, voxelData); // Front bottom
                        
                        _drawFrontSlice(  2,   4, 0, 12, 12, 0, 1, 0x0, voxelData); // Back
                        _drawFrontSlice(2+1, 4+1, 1, 10, 10, 0, 1, 0x0, voxelData); // Back inside

                        _drawTopSlice(  2, 4+11, 0+1, 12, 10, 0, 1, 0x0, voxelData); // Bottom
                        _drawTopSlice(2+1, 4+10, 0+2, 10,  9, 0, 1, 0x0, voxelData); // Bottom inside
                        _drawTopSlice(2+3, 4+10, 0+9,  8,  2, 0, 0, 0x0, voxelData); // Bottom inside hole
                        
                        _drawTopSlice(2+1, 4+1, 0+2, 10, 9, 0, 1, 0x0, voxelData); // Top inside
                        _drawTopSlice(2+2, 4+1, 0+2, 8, 9, 0, 0, 0x0, voxelData); // Top inside hole
                        
                        _drawTopSlice(2+0, 4+0, 0+1, 12, 10, 0, 1, 0x0, voxelData); // Top inside
                        _drawTopSlice(2+1, 4+0, 0+1, 10, 10, 0, 0, 0x0, voxelData); // Top inside hole
                    } else {
                        if (blockType < BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_TYPE_4_OSCILLOSCOPE) {
                            // Oscilloscope
                            _traitStrings[0] = "Oscilloscope";
                            paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_OSCILLOSCOPE_FRAME); // [1] Base
                            paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_BLACK); // [2] Secondary
                            paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_OSCILLOSCOPE_SIGNAL); // [3] Eyes
                            
                            _drawFrontSlice(  2,   4,   11, 12,  4, 4, 0, 0x111111111111_100000000001_100000000001_100000000001, voxelData); // Front top
                            _drawFrontSlice(  2,   8,   11, 12,  4, 4, 0, 0x100000000001_100000000001_100000000001_100000000001, voxelData); // Front mid
                            _drawFrontSlice(  2,  12,   11, 12,  4, 4, 0, 0x111111111111_111100001111_111100001111_111111111111, voxelData); // Front bottom
                            _drawFrontSlice(  2,  12, 11+1, 12,  4, 4, 0, 0x000000000000_011000000110_011000000110_000000000000, voxelData); // Front bottom outside
                            _drawFrontSlice(2+1, 4+1, 11-1, 10, 10, 0, 2, 0x0, voxelData); // Front inside
                            _drawFrontSlice(2+1, 4+3, 11-1, 10,  3, 4, 0, 0x2232222322_3323223233_2222332222, voxelData); // Front inside eyes
                            
                            _drawLeftSlice(2, 4, 0, 11, 12, 0, 1, 0x0, voxelData); // Left
                            
                            _drawTopSlice(2+1, 4, 0, 11, 11, 0, 1, 0x0, voxelData); // Top
                            
                            noEyes = false;
                        } else {
                            if (blockType < BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_TYPE_5_STEAMPUNK) {
                                // Steampunk
                                _traitStrings[0] = "Steampunk";
                                paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_BROWN_DARK); // [1] Base (Brown)
                                paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_BROWN_LIGHT); // [2] Secondary (Light brown)
                                paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_EYE_LIGHT); // [3] Eyes (Light blue)
                                paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GOLD_FC); // [4] Gears (Yellow)
                                paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GREY_4); // [5] Background (Dark grey)
                                paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GREY_7); // [6] Pipes (Grey)
                                paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GREY_A); // [7] Smoke (Light grey)
                                
                                _drawFrontSlice(  2,   4,   11, 12,  4, 4, 0, 0x111111111111_100000000001_100000000001_100000000001, voxelData); // Front top without eyes
                                _drawFrontSlice(  2,   8,   11, 12,  4, 4, 0, 0x100000000001_100000000001_100000000001_111111111111, voxelData); // Front mid without eyes
                                _drawFrontSlice(  2,  12,   11, 12,  4, 4, 0, 0x111111111111_100000000001_110000000011_111111111111, voxelData); // Front bottom
                                _drawFrontSlice(2+1, 4+1, 11-1, 10, 10, 0, 2, 0x0, voxelData); // Inner front
                                
                                _drawLeftSlice(2, 4, 0, 11, 12, 0, 1, 0x0, voxelData); // Left base (same as plain)
                                _drawLeftSlice(2+1, 4+2, 0+2, 8, 8, 0, 5, 0x0, voxelData); // Left inside
                                _drawLeftSlice(  2, 4+2, 0+2, 8, 8, 4, 0, 0x00440040_04444444_04444040_00440400_06004440_00000400_00600060_00000000, voxelData); // Left middle
                                _drawLeftSlice(2-1, 4+6, 0+3, 6, 3, 4, 0, 0x600000_000000_066666, voxelData); // Left outside
                                _drawLeftSlice(2-2, 4+1, 0+3, 1, 6, 4, 0, 0x707066, voxelData); // Left outside 2
                                
                                _drawTopSlice(2+1, 4, 0, 11, 11, 0, 1, 0x0, voxelData); // Top
                            } else {
                                if (blockType < BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_TYPE_6_ALIEN) {
                                    // Alien
                                    _traitStrings[0] = "Alien";
                                    paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_PURPLE_MID); // [1] Base (Purple)
                                    paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_PURPLE_DARK); // [2] Secondary (Dark purple)
                                    paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_PURPLE_LIGHT); // [3] Eyes (Light purple)
                                    paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_BLACK); // [4] Around eyes (Black)
                                    
                                    _drawFrontSlice(2,  4, 11, 12, 4, 4, 0, 0x001111111100_044400004440_444440044444_444430034444, voxelData); // Front top without eyes
                                    _drawFrontSlice(2,  8, 11, 12, 4, 4, 0, 0x444440044444_044400004440_111111111111_011111111110, voxelData); // Front mid without eyes
                                    _drawFrontSlice(2, 12, 11, 12, 4, 4, 0, 0x011111111110_011111111110_011100001110_001111111100, voxelData); // Front bottom
                                    _drawFrontSlice(2+1, 4+1, 11-1, 10, 10, 0, 2, 0x0, voxelData); // Inner front
                                    _drawFrontSlice(2+2, 4+9, 11-1,  8,  2, 0, 4, 0x0, voxelData); // Inner front bottom (mouth)
                                    _drawLeftSlice(2,  4, 0, 11, 4, 4, 0, 0x01111111110_11111111111_11113331111_11113331111, voxelData); // Left top
                                    _drawLeftSlice(2,  8, 0, 11, 4, 4, 0, 0x11113331111_11113331111_11113331111_11113331111, voxelData); // Left mid
                                    _drawLeftSlice(2, 12, 0, 11, 4, 4, 0, 0x11113331111_11113331111_11111111111_01111111110, voxelData); // Left bottom
                                    _drawTopSlice(2+1, 4, 0, 11, 4, 4, 0, 0x11111111110_33333333331_11111111111_33333333331, voxelData); // Top back
                                    _drawTopSlice(2+1, 4, 4, 11, 4, 4, 0, 0x11111111111_33333333331_11111111111_33333333331, voxelData); // Top mid
                                    _drawTopSlice(2+1, 4, 8, 11, 3, 4, 0, 0x11111111111_33333333331_11111111110, voxelData); // Top front

                                    noEyes = false;
                                } else {
                                    if (blockType < BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_TYPE_7_PSYCHEDELIC) {
                                        // Psychedelic
                                        _traitStrings[0] = "Psychedelic";
                                        paletteLength = _addPaletteColor(palette, paletteLength, 0x000066); // [1] Base (#1, Blue)
                                        paletteLength = _addPaletteColor(palette, paletteLength, 0xBBBBBB); // [2] Secondary (Grey)
                                        paletteLength = _addPaletteColor(palette, paletteLength, 0xFFFFCC); // [3] Eyes (Cream)
                                        paletteLength = _addPaletteColor(palette, paletteLength, 0x000022); // [4] Corners (Black)
                                        paletteLength = _addPaletteColor(palette, paletteLength, 0x660099); // [5] Gradient (#2, Purple)
                                        paletteLength = _addPaletteColor(palette, paletteLength, 0x990099); // [6] Gradient (#3, Voilet)
                                        paletteLength = _addPaletteColor(palette, paletteLength, 0xCC3333); // [7] Gradient (#4, Red)
                                        paletteLength = _addPaletteColor(palette, paletteLength, 0xFF9933); // [8] Gradient (#5, Orange)

                                        _drawFrontSlice(2,  4, 11, 12, 4, 4, 0, 0x411111111114_100000000001_100000000001_100000000001, voxelData); // Front top without eyes
                                        _drawFrontSlice(2,  8, 11, 12, 4, 4, 0, 0x100000000001_100000000001_100000000001_156783387651, voxelData); // Front mid without eyes
                                        _drawFrontSlice(2, 12, 11, 12, 4, 4, 0, 0x111111111111_100000000001_110000000011_415678876514, voxelData); // Front bottom
                                        _drawFrontSlice(2+1, 4+1, 11-1, 10, 10, 0, 2, 0x0, voxelData); // Inner front
                                        _drawLeftSlice(2,  4, 0, 11, 4, 4, 0, 0x41111111111_15555555555_15666666665_15677777765, voxelData); // Left top
                                        _drawLeftSlice(2,  8, 0, 11, 4, 4, 0, 0x15678888765_15678228765_15678228765_15678888765, voxelData); // Left mid
                                        _drawLeftSlice(2, 12, 0, 11, 4, 4, 0, 0x15677777765_15666666665_15555555555_41111111111, voxelData); // Left bottom

                                        _drawTopSlice(2+1, 4, 0, 11, 4, 4, 0, 0x11111111114_55555555551_56666666651_56777777651, voxelData); // Top back
                                        _drawTopSlice(2+1, 4, 4, 11, 4, 4, 0, 0x56788887651_56782287651_56782287651_56788887651, voxelData); // Top mid
                                        _drawTopSlice(2+1, 4, 8, 11, 3, 4, 0, 0x56777777651_56666666651_55555555551, voxelData); // Top front
                                    } else {
                                        if (blockType < BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_TYPE_8_ZOMBIE) {
                                            // Zombie
                                            _traitStrings[0] = "Zombie";
                                            paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GREEN_DARK); // [1] Base
                                            paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GREEN_LIGHT); // [2] Secondary
                                            paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_BLACK); // [3] Eyes

                                            _drawFrontSlice(2,  4, 11, 12, 4, 4, 0, 0x011111111110_100000000001_100000000001_100000000001, voxelData); // Front top without eyes
                                            _drawFrontSlice(2,  8, 11, 12, 4, 4, 0, 0x100000000001_100000000001_100000000001_111111111111, voxelData); // Front mid without eyes
                                            _drawFrontSlice(2, 12, 11, 12, 4, 4, 0, 0x111111111111_100000000001_110000000011_011111111110, voxelData); // Front bottom
                                            _drawFrontSlice(2+1, 4+1, 11-1, 10, 10, 0, 2, 0x0, voxelData); // Inner front
                                            _drawLeftSlice(2,  4, 0, 11, 4, 4, 0, 0x01100110011_11100110011_11100110011_11110111011, voxelData); // Left top
                                            _drawLeftSlice(2,  8, 0, 11, 2, 4, 0, 0x11110111011_11110111011, voxelData); // Left mid
                                            _drawLeftSlice(2, 10, 0, 11, 6, 0, 1, 0x0, voxelData); // Left bottom
                                            //_drawLeftSlice(2+1,  4+1, 0+1, 11, 10, 0, 1, 0x01100110011_11100110011_11100110011_11110111011, voxelData); // Left inner
                                            _drawLeftSlice(2+1,  4+1, 0+2, 8, 6, 0, 1, 0x0, voxelData); // Left inner
                                            _drawTopSlice(2+1, 4, 0, 11, 4, 4, 0, 0x11111111110_11111111111_12111111211_11111111111, voxelData); // Top back
                                            _drawTopSlice(2+1, 4, 4, 11, 4, 4, 0, 0x11111111111_12111111211_11111111111_11111111111, voxelData); // Top mid
                                            _drawTopSlice(2+1, 4, 8, 11, 3, 4, 0, 0x12111111211_11111111111_11111111111, voxelData); // Top front
                                        } else {
                                            if (blockType < BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_TYPE_9_CAMOUFLAGE) {
                                                // Camouflage
                                                _traitStrings[0] = "Camouflage";
                                                paletteLength = _addPaletteColor(palette, paletteLength, 0xBBCFC5); // [1] Base (#4)
                                                //paletteLength = _addPaletteColor(palette, paletteLength, 0x222222); // [2] Secondary (#1)
                                                paletteLength = _addPaletteColor(palette, paletteLength, 0x3B4642); // [2] Secondary (#2)
                                                paletteLength = _addPaletteColor(palette, paletteLength, 0x111111); // [3] Eyes
                                                paletteLength = _addPaletteColor(palette, paletteLength, 0x76837B); // [4] Gradient (#3)
                                                paletteLength = _addPaletteColor(palette, paletteLength, 0x3B4642); // [5] Gradient (#2)

                                                _drawFrontSlice(2, 4, 11, 12, 4, 4, 0,  0x155414115511_400000000001_100000000004_100000000005, voxelData); // Front top without eyes
                                                _drawFrontSlice(2, 8, 11, 12, 4, 4, 0,  0x500000000001_400000000001_100000000001_411114551114, voxelData); // Front mid without eyes
                                                _drawFrontSlice(2, 12, 11, 12, 4, 4, 0, 0x514411111445_100000000001_110000000011_144551111145, voxelData); // Front bottom
                                                _drawFrontSlice(2+1, 4+1, 11-1, 10, 10, 0, 2, 0x0, voxelData); // Inner front
                                                
                                                _drawLeftSlice(2,  4, 0, 11, 4, 4, 0, 0x11444511444_45111111111_45115441444_44114411111, voxelData); // Left top
                                                _drawLeftSlice(2,  8, 0, 11, 4, 4, 0, 0x11411114541_54114114441_44144411141_11445414441, voxelData); // Left mid
                                                _drawLeftSlice(2, 12, 0, 11, 4, 4, 0, 0x41111414441_14411111111_14554111555_11111441444, voxelData); // Left bottom
                                                _drawTopSlice(2+1, 4, 0, 11, 4, 4, 0, 0x45111111111_11544444141_14441145141_14111145151, voxelData); // Top back
                                                _drawTopSlice(2+1, 4, 4, 11, 4, 4, 0, 0x41114551454_14414551144_15441111441_11111141551, voxelData); // Top mid
                                                _drawTopSlice(2+1, 4, 8, 11, 3, 4, 0, 0x44514551551_14414441441_14411111114, voxelData); // Top front
                                            } else {
                                                if (blockType < BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_TYPE_12_PINK_GRAD) {
                                                    // Gradients - Gold / Blue / Pink
                                                    if (blockType < BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_TYPE_10_GOLD) {
                                                    // Gold
                                                    _traitStrings[0] = "Gold";
                                                    paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GOLD_FD); // [1] Base (#5)
                                                    paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GOLD_C); // [2] Secondary (#2)
                                                    paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_EYE); // [3] Eyes
                                                    paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GOLD_FC); // [4] Gradient (#4)
                                                    paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GOLD_FB); // [5] Gradient (#3)
                                                    paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GOLD_A); // [6] Gradient (#1)
                                                    } else {
                                                        if (blockType < BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_TYPE_11_BLUE_GRAD) {
                                                            // Blue gradient
                                                            _traitStrings[0] = "Blue gradient";
                                                            paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_BABY_BLUE); // [1] Base (#5)
                                                            paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_BABY_BLUE_DARK); // [2] Secondary (#2)
                                                            paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_EYE_DARK); // [3] Eyes
                                                            paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_BABY_BLUE_D); // [4] Gradient (#4)
                                                            paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_BABY_BLUE_C); // [5] Gradient (#3)
                                                            paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_BABY_BLUE_9); // [6] Gradient (#1)
                                                        } else {
                                                            // Pink gradient
                                                            _traitStrings[0] = "Pink gradient";
                                                            paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_PINK); // [1] Base (#5)
                                                            paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_PINK_DARK); // [2] Secondary (#2)
                                                            paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_EYE); // [3] Eyes
                                                            paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_PINK_D); // [4] Gradient (#4)
                                                            paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_PINK_B); // [5] Gradient (#3)
                                                            paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_PINK_8); // [6] Gradient (#1)
                                                        }
                                                    }
                                                    _drawFrontSlice(2, 4, 11, 12, 4, 4, 0,  0x444444444444_400000000004_400000000004_400000000004, voxelData); // Front top without eyes
                                                    _drawFrontSlice(2, 8, 11, 12, 4, 4, 0,  0x400000000004_400000000004_400000000004_411111111114, voxelData); // Front mid without eyes
                                                    _drawFrontSlice(2, 12, 11, 12, 4, 4, 0, 0x411111111114_400000000004_410000000014_444444444444, voxelData); // Front bottom
                                                    _drawFrontSlice(2+1, 4+1, 11-1, 10, 10, 0, 2, 0x0, voxelData); // Inner front

                                                    _drawLeftSlice(2, 4, 0, 3, 12, 0, 6, 0x0, voxelData); // Left back to front #1
                                                    _drawLeftSlice(2, 4, 3, 3, 12, 0, 2, 0x0, voxelData); // Left back to front #2
                                                    _drawLeftSlice(2, 4, 6, 3, 12, 0, 5, 0x0, voxelData); // Left back to front #3
                                                    _drawLeftSlice(2, 4, 9, 2, 12, 0, 4, 0x0, voxelData); // Left back to front #4

                                                    _drawTopSlice(2+1, 4, 0, 11, 3, 0, 6, 0x0, voxelData); // Top back to front #1
                                                    _drawTopSlice(2+1, 4, 3, 11, 3, 0, 2, 0x0, voxelData); // Top back to front #2
                                                    _drawTopSlice(2+1, 4, 6, 11, 3, 0, 5, 0x0, voxelData); // Top back to front #3
                                                    _drawTopSlice(2+1, 4, 9, 11, 2, 0, 4, 0x0, voxelData); // Top back to front #4
                                                } else {
                                                    colorType = true;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                if (colorType) {
                    if (true) {
                        uint256 blockTypeColors = (blockType - BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_TYPE_12_PINK_GRAD) / ((256 - BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_TYPE_12_PINK_GRAD) / 25);
                        uint256 primaryColor = blockTypeColors / 5;
                        uint256 secondaryColor = blockTypeColors % 5;
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
                    
                    _drawFrontSlice(2,  4, 11, 12, 4, 4, 0, 0x111111111111_100000000001_100000000001_100000000001, voxelData); // Front top without eyes
                    _drawFrontSlice(2,  8, 11, 12, 4, 4, 0, 0x100000000001_100000000001_100000000001_111111111111, voxelData); // Front mid without eyes
                    _drawFrontSlice(2, 12, 11, 12, 4, 4, 0, 0x111111111111_100000000001_110000000011_111111111111, voxelData); // Front bottom
                    _drawFrontSlice(2+1, 4+1, 11-1, 10, 10, 0, 2, 0x0, voxelData); // Inner front
                    _drawLeftSlice(2, 4, 0, 11, 12, 0, 1, 0x0, voxelData); // Left
                    _drawTopSlice(2+1, 4, 0, 11, 11, 0, 1, 0x0, voxelData); // Top
                }
                if (!colorType) {
                    _traitStrings[1] = "Normal";
                }
            }

            // Mouth
            if (true) {
                uint256 mouth = (tokenVisuals >> 32) & 0xff;
                bool hasCigarette = false;

                if (mouth < BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_MOUTH_0_GAS_MASK) {
                    // Gas mask
                    _traitStrings[5] = "Gas mask";
                    _drawFrontSlice(2+2, 4+4, 11+1,  8, 3, 4, paletteLength - 2, 0x00022000_02222220_22222222, voxelData); // Front top
                    _drawFrontSlice(  2, 4+7, 11+1, 12, 5, 0, paletteLength, 0x0, voxelData); // Front bottom
                    _drawFrontSlice(2+4, 4+6, 11+2,  4, 3, 4, paletteLength - 2, 0x0330_3443_3333, voxelData); // Front holes top
                    _drawFrontSlice(  2, 4+9, 11+2, 12, 3, 4, paletteLength - 2, 0x330000000033_430000000034_330000000033, voxelData); // Front holes bottom
                    _drawLeftSlice( 2-1, 4+8, 11, 2, 4, 4, paletteLength - 2, 0x02_33_34_33, voxelData); // Left
                    _drawLeftSlice(2+12, 4+8, 11, 2, 4, 4, paletteLength - 2, 0x02_33_34_33, voxelData); // Right
                    paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GREY_2); // Mask
                    paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GREEN_DARK); // Hole around
                    paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GREY_4); // Hole inside
                } else {
                    if (mouth < BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_MOUTH_1_MASK) {
                        // Mask
                        _traitStrings[5] = "Mask";
                        _drawFrontSlice(2, 4+4, 11+1, 12, 4, 4, paletteLength - 2, 0x200022220002_222220022222_202000000202_222222222222, voxelData); // Front top
                        _drawFrontSlice(2, 4+8, 11+1, 12, 4, 4, paletteLength - 2, 0x002020020200_002020020200_002020020200_002222222200, voxelData); // Front bottom
                        paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GREY_2); // Around
                    } else {
                        if (mouth < BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_MOUTH_2_TEETH_CIG) {
                            hasCigarette = true;
                        }
                        if (mouth < BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_MOUTH_3_TEETH) {
                            // Teeth
                            _traitStrings[5] = "Teeth";
                            _drawFrontSlice(2+1, 4+6, 11, 10, 5, 4, paletteLength - 2, 0x1000000001_1111111111_0010000100_0010000100_1111111111, voxelData); // Front
                            _drawFrontSlice(2+1, 4+8, 11-1, 10, 2, 4, paletteLength - 2, 0x2222222222_2222222222, voxelData); // Front inside
                            paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GREY_2); // Mouth
                        } else {
                            if (mouth < BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_MOUTH_4_STRAIGHT_CIG) {
                                hasCigarette = true;
                            }
                            if (mouth < BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_MOUTH_5_STRAIGHT) {
                                // Straight
                                _traitStrings[5] = "Straight";
                                _drawFrontSlice(2+1, 4+6, 11, 10, 5, 4, paletteLength - 2, 0x1000000001_1111111111_0000000000_0000000000_1111111111, voxelData); // Front
                                // Second mouth row skipped
                                _drawFrontSlice(2+1, 4+6, 11, 10, 1, 4, paletteLength - 2, 0x1000000001, voxelData); // Front top
                                _drawFrontSlice(2+1, 4+8, 11, 10, 3, 4, paletteLength - 2, 0x0000000000_0000000000_1111111111, voxelData); // Front bottom

                                _drawFrontSlice(2+1, 4+8, 11-1, 10, 2, 4, paletteLength - 2, 0x2222222222_2222222222, voxelData); // Front inside
                                paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GREY_4); // Mouth
                            } else {
                                if (mouth < BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_MOUTH_6_SMILE_CIG) {
                                    hasCigarette = true;
                                }
                                // Smile
                                _traitStrings[5] = "Smile";
                            }
                        }
                        if (hasCigarette) {
                            // Cigarette
                            _traitStrings[5] = string(abi.encodePacked(_traitStrings[5], " with cigarette"));
                            _drawFrontSlice(2+9, 4+0, 11+2, 1, 8, 4, paletteLength - 2, 0x40004004, voxelData); // Front
                            _drawLeftSlice(2+9, 4+9, 11-1, 4, 1, 4, paletteLength - 2, 0x2223, voxelData); // Left
                            paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_WHITE); // Cigarette
                            paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_RED); // Cigarette end
                            paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GREY_A); // Smoke
                        }
                    }
                }
            }

            // Eyes
            if (true) {
                uint256 eyes = (tokenVisuals >> 24) & 0xff;
                bool needsEyes = false;

                if (eyes < BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_EYES_0_RAINBOW) {
                    // Rainbow
                    _traitStrings[4] = "Rainbow";
                    _drawFrontSlice(2+1, 4+1, 11-1, 10, 6, 4, paletteLength - 2, 0x2233445566_2233445566_2233445566_2233445566_2233115566_2233115566, voxelData); // Front
                    _drawFrontSlice(2+5, 4+5, 11+0, 2, 2, 4, paletteLength - 2, 0x11_11, voxelData); // Nose
                    paletteLength = _addPaletteColor(palette, paletteLength, 0xFF0000); // Red
                    paletteLength = _addPaletteColor(palette, paletteLength, 0xFF9900); // Orange
                    paletteLength = _addPaletteColor(palette, paletteLength, 0xFFFF00); // Yellow
                    paletteLength = _addPaletteColor(palette, paletteLength, 0x66FF66); // Green
                    paletteLength = _addPaletteColor(palette, paletteLength, 0x3366FF); // Blue
                } else {
                    if (eyes < BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_EYES_1_VISOR) {
                        // Visor
                        _traitStrings[4] = "Visor";
                        _drawFrontSlice(2-1, 4+1, 11+1, 14, 4, 4, paletteLength - 2, 0x22222000022222_33333333333333_44444444444444_55555000055555, voxelData); // Front
                        _drawLeftSlice(2-1, 4+2, 0+10, 2, 2, 4, paletteLength - 2, 0x33_44, voxelData); // Left
                        _drawLeftSlice(2+12, 4+2, 0+10, 2, 2, 4, paletteLength - 2, 0x33_44, voxelData); // Left
                        paletteLength = _addPaletteColor(palette, paletteLength, 0x000055); // Top blue
                        paletteLength = _addPaletteColor(palette, paletteLength, 0x000077); // 2nd blue
                        paletteLength = _addPaletteColor(palette, paletteLength, 0x0000AA); // 3rd blue
                        paletteLength = _addPaletteColor(palette, paletteLength, 0x0000EE); // Bottom blue
                        needsEyes = true;
                    } else {
                        if (eyes < BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_EYES_2_3D_GLASSES) {
                            // 3D glasses
                            _traitStrings[4] = "3D glasses";
                            _drawFrontSlice(2-1, 4+2, 11+1, 14, 3, 4, paletteLength - 2, 0x22222222222222_02333200244420_02222200222220, voxelData); // Front
                            _drawLeftSlice(2-1, 4+2, 0+4, 8, 3, 4, paletteLength - 2, 0x22222222_20000000_20000000, voxelData); // Left
                            _drawLeftSlice(2+12, 4+2, 0+4, 8, 3, 4, paletteLength - 2, 0x22222222_20000000_20000000, voxelData); // Right
                            paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_WHITE); // Glasses
                            paletteLength = _addPaletteColor(palette, paletteLength, 0x0099FF); // Blue
                            paletteLength = _addPaletteColor(palette, paletteLength, 0xEE0000); // Red
                            needsEyes = true;
                        } else {
                            if (eyes < BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_EYES_3_SUNGLASSES) {
                                // Sunglasses
                                _traitStrings[4] = "Sunglasses";
                                _drawFrontSlice(2-1, 4+2, 11+1, 14, 3, 4, paletteLength - 2, 0x22222222222222_00222200222200_00222000022200, voxelData); // Front
                                _drawLeftSlice(2-1, 4+2, 0+4, 8, 2, 4, paletteLength - 2, 0x22222222_20000000, voxelData); // Left
                                _drawLeftSlice(2+12, 4+2, 0+4, 8, 2, 4, paletteLength - 2, 0x22222222_20000000, voxelData); // Right
                                paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GREY_2); // Glasses
                                needsEyes = true;
                            } else {
                                if (eyes < BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_EYES_4_CYCLOPS) {
                                    // Cyclops
                                    _traitStrings[4] = "Cyclops";
                                    _drawFrontSlice(2+4, 4+2, 11, 4, 3, 4, 0, 0x0110_1331_0110, voxelData);
                                } else {
                                    if (eyes < BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_EYES_5_CYCLOPS_VISOR) {
                                        // Cyclops visor
                                        _traitStrings[4] = "Cyclops visor";
                                        _drawFrontSlice(2+1, 4+2, 11, 10, 3, 4, paletteLength - 2, 0x2222222222_2333333332_2222222222, voxelData);
                                        paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GREY_2); // Around
                                        paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_EYE_RED); // Eyes
                                    } else {
                                        if (eyes < BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_EYES_6_RED_EYE) {
                                            // Red eyes
                                            _traitStrings[4] = "Red";
                                            _drawFrontSlice(2+1, 4+2, 11, 10, 3, 4, paletteLength - 2, 0x2222002222_2332002332_2222002222, voxelData);
                                            paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_BLACK); // Around
                                            paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_EYE_RED); // Eyes
                                        } else {
                                            _traitStrings[4] = "Plain";
                                            needsEyes = true;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                if (noEyes && needsEyes) {
                    _drawFrontSlice(2+1, 4+2, 11, 10, 3, 4, 0, 0x1110000111_1331001331_1110000111, voxelData);
                }
            }

            // Top
            if (true) {
                uint256 top = (tokenVisuals >> 16) & 0xff;

                if (top < BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_TOP_0_ELECTRONIC) {
                        _traitStrings[3] = "Electronic";
                        // Electronic
                        _drawTopSlice(2+2, 4-1, 0+2,   8,  8,  4, paletteLength, 0x00000000_20002220_22202020_20222020_20000020_00222222_00200000_00000000, voxelData); // Top
                        _drawTopSlice(2+1, 4,   0+1,   10, 5,  4, paletteLength - 1, 0x0200020002_0202220222_3302033302_0333030332_0303330302, voxelData); // Mid back
                        _drawTopSlice(2+1, 4,   0+1+5, 10, 5,  4, paletteLength - 1, 0x3303030302_0203333332_0202030302_0222022202_0002000200, voxelData); // Mid front
                        _drawTopSlice(2+1, 4+1, 0+1,   10, 9,  0, paletteLength, 0, voxelData); // Mid front
                        
                        paletteLength = _addPaletteColor(palette, paletteLength, 0x440000); // Base
                        paletteLength = _addPaletteColor(palette, paletteLength, 0xBB0000); // Mid
                        paletteLength = _addPaletteColor(palette, paletteLength, 0xEE0000); // Top
                } else {
                    if (top < BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_TOP_3_HOODIE_PINK) {
                        // Hoodies
                        _drawLeftSlice(2, 4-1,  0+0, 13, 13, 0,     paletteLength, 0x0, voxelData); // Left side
                        _drawLeftSlice(2, 4-1, 11+2,  2,  6, 4, paletteLength - 2, 0x22_22_20_20_20_20, voxelData); // Left front
                        _drawLeftSlice(2, 4-1,  0+0 , 2,  2, 4, paletteLength - 2, 0x00_02, voxelData); // Left back
                        
                        _drawLeftSlice(13, 4-1,  0+0, 13, 13, 0,     paletteLength, 0x0, voxelData); // Right side
                        _drawLeftSlice(13, 4-1, 11+2,  2,  6, 4, paletteLength - 2, 0x22_22_20_20_20_20, voxelData); // Right front
                        _drawLeftSlice(13, 4-1,  0+0 , 2,  2, 4, paletteLength - 2, 0x00_02, voxelData); // Right back
                        
                        _drawTopSlice(2+1, 4-1,    0, 10, 15, 0,     paletteLength, 0x0, voxelData); // Top base
                        _drawTopSlice(2+1, 4-1,    0, 10,  1, 4, paletteLength - 2, 0x0222222220, voxelData); // Top base back
                        _drawTopSlice(2+1, 4+0,    0, 10,  1, 0,     paletteLength, 0x0, voxelData); // Back
                        _drawTopSlice(2+2, 4-2,  0+2,  8, 10, 0,     paletteLength, 0x0, voxelData); // Top upper
                        _drawTopSlice(2+3, 4-2, 11+1,  6,  1, 0,     paletteLength, 0x0, voxelData); // Top upper front

                        if (top < BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_TOP_1_HOODIE_GREY) {
                            // Grey hoodie
                            _traitStrings[3] = "Grey hoodie";
                            paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GREY_5); // Grey hoodie
                        } else {
                            if (top < BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_TOP_2_HOODIE_BLUE) {
                                // Blue hoodie
                                _traitStrings[3] = "Blue hoodie";
                                paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_BABY_BLUE_DARK); // Blue hoodie
                            } else {
                                // Pink hoodie
                                _traitStrings[3] = "Pink hoodie";
                                paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_PINK_DARK); // Pink hoodie
                            }
                        }
                    } else {
                        if (top < BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_TOP_4_MOHAWK) {
                            _traitStrings[3] = "Mohawk";
                            // Mohawk
                            _drawTopSlice(2+5, 4-1, 0, 2, 12, 0, paletteLength, 0x0, voxelData);
                            paletteLength = _addPaletteColor(palette, paletteLength, 0x000055); // Hair
                        } else {
                            if (top < BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_TOP_5_HAIR) {
                                _traitStrings[3] = "Hair";
                                // Hair
                                _drawTopSlice(2+1, 4, 0, 10, 12, 0, paletteLength, 0x0, voxelData); // Base
                                _drawTopSlice(2+1, 4-1,   0, 10, 6, 4, paletteLength - 2, 0x0200200202_0202200202_2200202200_0200200202_0202020022_2002020200, voxelData); // Top back
                                _drawTopSlice(2+1, 4-1, 0+6, 10, 6, 4, paletteLength - 2, 0x2202020202_0200200022_0202020220_0202022002_0200002002_0000000000, voxelData); // Top front
                                paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GREY_3); // Hair
                            } else {
                                // Plain
                                _traitStrings[3] = "Plain";
                            }
                        }
                    }

                }
            }

            // Side
            if (true) {
                uint256 side = (tokenVisuals >> 8) & 0xff;
                if (side < BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_SIDE_0_CIRCUIT_BOARD) {
                        // Circuit board
                        _traitStrings[2] = "Circuit board";
                        _drawLeftSlice(2+2, 4+2, 0+2, 8, 8, 0, paletteLength + 2, 0x0, voxelData); // Background
                        _drawLeftSlice(2+1, 4+1, 0+1, 10, 10, 0, 1, 0x0, voxelData); // Frame (center replaced below)
                        _drawLeftSlice(2+1, 4+2, 0+2, 8, 8, 4, paletteLength - 2, 0x00000000_00022222_06622442_00022442_00022232_22023332_22624242_42022222, voxelData); // Base
                        _drawLeftSlice(2, 4+2, 0+2, 8, 8, 4, paletteLength - 2, 0x00000000_00000000_00005000_00000000_00000000_50000000_00000000_00000000, voxelData); // Top
                        paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GREEN_DARK); // Dark green
                        paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GREEN_LIGHT); // Light green
                        paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GREY_4); // Dark grey
                        paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GREY_8); // Mid grey
                        paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_GREY_D ); // Bright grey
                } else {
                    if (side < BLOCKHEAD_TRAIT_CUMULATIVE_LIKELIHOOD_SIDE_1_HEADPHONES) {
                        // Headphones
                        _traitStrings[2] = "Headphones";
                        _drawTopSlice(2, 4-1, 5, 12, 1, 0, paletteLength, 0x0, voxelData); // Top
                        _drawLeftSlice(2-1, 4-1, 0+3, 5, 8, 4, paletteLength - 2, uint256(uint160(0x00200_00200_00200_22222_22222_22222_22222_22222)), voxelData); // Left
                        _drawLeftSlice(2+12, 4-1, 0+3, 5, 8, 4, paletteLength - 2, uint256(uint160(0x00200_00200_00200_22222_22222_22222_22222_22222)), voxelData); // Right
                        paletteLength = _addPaletteColor(palette, paletteLength, PALETTE_RED);
                    } else {
                        _traitStrings[2] = "Plain";
                    }
                }
            }
        }

        // Power bar
        if (true) {

            uint256 winCount = (tokenVisuals >> (40 + 24)) & 0xff;
            uint256 hideWinbar = (tokenVisuals >> (40 + 40)) & 0xff;
            if (hideWinbar == 0) { // Display toggle
                winCount = winCount;
                uint scoreCategory = 0;
                if (winCount > 5) {
                    uint256 matchCount = (tokenVisuals >> (40 + 16)) & 0xff;
                    scoreCategory = (winCount * 8) / matchCount;
                }
                
                for (uint256 i = 0; i < scoreCategory * 2; i++) {
                    _drawTopSlice(13-i, 0, 0, 1, 1, 0, paletteLength + (i / 2), 0x0, voxelData);
                    _drawTopSlice(13, 0, 0+i, 1, 1, 0, paletteLength + (i / 2), 0x0, voxelData);
                }
                
                paletteLength = _addPaletteColor(palette, paletteLength, 0xFF0000);
                paletteLength = _addPaletteColor(palette, paletteLength, 0xFF4800);
                paletteLength = _addPaletteColor(palette, paletteLength, 0xFF7000);
                paletteLength = _addPaletteColor(palette, paletteLength, 0xFFC000);
                paletteLength = _addPaletteColor(palette, paletteLength, 0xFFD800);
                paletteLength = _addPaletteColor(palette, paletteLength, 0xFFF800);
            }
        }
        


        // Generate SVG representation
        _appendVoxelData(svgString, voxelData, tokenHash);

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

            _appendString(svgString, "'/>\n<polygon points='4100000,4100000 4100000,4200000 4186602,4150000 4186602,4050000' fill='#");
            _appendString(svgString, _colorHexToString(color));

            _appendString(svgString, "'/>\n<polygon points='4100000,4100000 4013397,4050000 4100000,4000000 4186602,4050000' fill='#");
            _appendString(svgString, _colorHexToString(colorBright));

            _appendString(svgString, "'/>\n</g>\n");
        }
        _appendString(svgString, '</defs>\n');

        _appendString(svgString, '</svg>\n');

        svgStringFullString = svgString.fullString;
        svgStringLength = svgString.length;
    }

    function formatURI(uint256 tokenId, uint256 tokenData) public view returns (string memory uri) {
        uint256 extraLength = 0;
        if (blockheads3dContractAddress != address(0)) {
            extraLength = Blockheads3dForUtilityFormatting(blockheads3dContractAddress).getExtraLength();
        }

        bytes memory uriBytes = new bytes(10000+188*400+20*400 + 0 + 40*400 + 0 + 100*400 + 75000 + extraLength);

        ExtensibleString memory uriString;
        uriString.length = 0;
        uriString.fullString = string(uriBytes);

        uint256 callingContract = 0;
        if (msg.sender == blockletsContractAddress) {
            callingContract = 1;
        } else {
            if (msg.sender == blocktrophiesContractAddress) {
                callingContract = 2;
            }
        }
        
        string memory string_trait_type = '    {\n      "trait_type": "';
        string memory string_trait_value = '",\n      "value": "';
        string memory string_trait_after = '"\n    },\n';
        string memory string_trait_last = '"\n    }\n';
        
        _appendString(uriString, '{\n');

        if (callingContract == 0) {
            _appendString(uriString, '  "name": "Blockhead #');
        } else {
            if (callingContract == 1) {
                _appendString(uriString, '  "name": "Blocklet #');
            } else {
                _appendString(uriString, '  "name": "Blocktrophy #');
            }
        }
        _appendString(uriString, Strings.toString(tokenId));
        _appendString(uriString, '",\n');

        if (callingContract == 0) {
            _appendString(uriString, '  "description": "Blockheads are a limited collection of fully on-chain, gamified NFTs that push the limits of what is possible in an NFT smart contract.",\n');
        } else {
            if (callingContract == 1) {
                _appendString(uriString, '  "description": "Blocklets are a limited collection of fully on-chain, gamified NFTs that push the limits of what is possible in an NFT smart contract.",\n');
            } else {
                _appendString(uriString, '  "description": "Blocktrophies are a limited collection of fully on-chain, gamified NFTs that push the limits of what is possible in an NFT smart contract.",\n');
            }
        }

        _appendString(uriString, '  "data": "');
        _appendString(uriString, Strings.toHexString(tokenData, 32));
        _appendString(uriString, '",\n');

        _appendString(uriString, '  "image": "data:image/svg+xml;base64,');


        string[8] memory traitStrings;
        if (true) {
            (bool success, bytes memory returnedData) = msg.sender.staticcall(abi.encodeWithSignature("tokenSVG(uint256)", tokenId));
            (string memory svgString, uint256 svgLength, string[8] memory traitStrs) = abi.decode(returnedData, (string, uint256, string[8]));

            assembly { mstore(svgString, svgLength) }
            
            _appendString(uriString, base64encode(bytes(svgString)));

            _appendString(uriString, '",\n');

            traitStrings[0] = traitStrs[0]; traitStrings[1] = traitStrs[1]; traitStrings[2] = traitStrs[2]; traitStrings[3] = traitStrs[3];
            traitStrings[4] = traitStrs[4]; traitStrings[5] = traitStrs[5]; traitStrings[6] = traitStrs[6]; traitStrings[7] = traitStrs[7];
        }

        
        if (callingContract == 0) {
            if (blockheads3dContractAddress != address(0)) {
                _appendString(uriString, '  "');
                _appendString(uriString, Blockheads3dForUtilityFormatting(blockheads3dContractAddress).getFieldName());
                _appendString(uriString, '": "');
                _appendString(uriString, Blockheads3dForUtilityFormatting(blockheads3dContractAddress).getPrefix());

                string memory token3d = Blockheads3dForUtilityFormatting(blockheads3dContractAddress).token3d(tokenId);
                if (Blockheads3dForUtilityFormatting(blockheads3dContractAddress).getBase64()) {
                    _appendString(uriString, base64encode(bytes(token3d)));
                } else {
                    _appendString(uriString, token3d);
                }
                _appendString(uriString, '",\n');
            }
        }

        _appendString(uriString, '  "attributes": [\n');

        if (callingContract < 2) {
            _appendString(uriString, string_trait_type);
            _appendString(uriString, 'Type');
            _appendString(uriString, string_trait_value);
            _appendString(uriString, traitStrings[0]);
            _appendString(uriString, string_trait_after);

            _appendString(uriString, string_trait_type);
            _appendString(uriString, 'Face');
            _appendString(uriString, string_trait_value);
            _appendString(uriString, traitStrings[1]);
            if (callingContract == 0) {
                _appendString(uriString, string_trait_after);
            } else {
                _appendString(uriString, string_trait_last);
            }
        }

        if (callingContract == 0) {
            _appendString(uriString, string_trait_type);
            _appendString(uriString, 'Side');
            _appendString(uriString, string_trait_value);
            _appendString(uriString, traitStrings[2]);
            _appendString(uriString, string_trait_after);
            
            _appendString(uriString, string_trait_type);
            _appendString(uriString, 'Top');
            _appendString(uriString, string_trait_value);
            _appendString(uriString, traitStrings[3]);
            _appendString(uriString, string_trait_after);
            
            _appendString(uriString, string_trait_type);
            _appendString(uriString, 'Eyes');
            _appendString(uriString, string_trait_value);
            _appendString(uriString, traitStrings[4]);
            _appendString(uriString, string_trait_after);
            
            _appendString(uriString, string_trait_type);
            _appendString(uriString, 'Mouth');
            _appendString(uriString, string_trait_value);
            _appendString(uriString, traitStrings[5]);
            _appendString(uriString, string_trait_last);
        } else {
            if (callingContract == 2) {
            _appendString(uriString, string_trait_type);
            _appendString(uriString, 'Winner');
            _appendString(uriString, string_trait_value);
            _appendString(uriString, traitStrings[0]);
            _appendString(uriString, string_trait_after);
            
            _appendString(uriString, string_trait_type);
            _appendString(uriString, 'Date');
            _appendString(uriString, string_trait_value);
            _appendString(uriString, traitStrings[1]);
            _appendString(uriString, string_trait_after);

            _appendString(uriString, string_trait_type);
            _appendString(uriString, 'Color');
            _appendString(uriString, string_trait_value);
            _appendString(uriString, traitStrings[2]);
            _appendString(uriString, string_trait_after);
            
            _appendString(uriString, string_trait_type);
            _appendString(uriString, 'Blue score');
            _appendString(uriString, string_trait_value);
            _appendString(uriString, traitStrings[3]);
            _appendString(uriString, string_trait_after);
            
            _appendString(uriString, string_trait_type);
            _appendString(uriString, 'Red score');
            _appendString(uriString, string_trait_value);
            _appendString(uriString, traitStrings[4]);
            _appendString(uriString, string_trait_last);
            }
        }

        _appendString(uriString, '  ]\n');
        _appendString(uriString, '}\n');
        
        assembly {mstore(mload(add(uriString, 0x20)), mload(uriString))}

        string memory base64json = base64encode(bytes(uriString.fullString));
        
        bytes memory jsonBytes = new bytes(29 + bytes(base64json).length * 2);
        ExtensibleString memory jsonString;
        jsonString.length = 0;
        jsonString.fullString = string(jsonBytes);
        _appendString(jsonString, "data:application/json;base64,");
        _appendString(jsonString, base64json);

        assembly {mstore(mload(add(jsonString, 0x20)), mload(jsonString))}
        
        return jsonString.fullString;
    }
}