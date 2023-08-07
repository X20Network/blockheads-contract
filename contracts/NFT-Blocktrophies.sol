// SPDX-License-Identifier: All Rights Reserved
// Copyright 2023 Blockheads.network. All Rights Reserved.
pragma solidity >=0.8.0;

import "./token/ERC721/extensions/ERC721Enumerable.sol";
import "./utils/Strings.sol";

abstract contract BlockballReplay {
    function play(uint256 rounds, bytes32 seed, uint32[8] memory ps, bool allStates) public view virtual returns (uint256[] memory states);
}

abstract contract UtilityFormattingForBlocktrophies {
    function formatURI(uint256 tokenId, uint256 tokenData) public view virtual returns (string memory);
}

contract Blocktrophies is ERC721Enumerable {

    struct MatchPlayers {
        uint32[8] players;
    }

    bool finalized;
    uint256 tokensPreset;
    mapping (uint256 => uint256) tokenData;
    uint256 tokenCount;
    
    mapping (uint256 => uint32[8]) tokenPlayers;
    mapping (uint256 => bytes32) tokenSeed;

    uint256 constant START_TIME = 5;

    address owner;
    address public blockheadsContractAddress;
    address public blockballContractAddress;
    address public blockmintingContractAddress;
    address public blockletsContractAddress;
    address public blocktrophiesContractAddress;
    address public utilityFormattingContractAddress;
    
    address public engravingBlocktrophiesContractAddress;
    constructor(address blockheads) ERC721("Blocktrophies", "BLOCKTROPHY")  {
        owner = msg.sender;
        blockheadsContractAddress = blockheads;
        
        finalized = false;
        tokensPreset = 0;
        tokenCount = 0;
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

    function presetTokens(uint256[] calldata data) public {
        require(msg.sender == owner);
        require(finalized == false);
        for (uint256 i = 0; i < data.length; i++) {
            tokenData[tokensPreset + i] = data[i];
        }
        tokensPreset += data.length;
    }

    function awardTrophy(address userAddress, uint32[8] memory players, bytes32 seed, uint256 scoreBlue, uint256 scoreRed, uint256 tournamentDate) public returns (uint256 trophyId) {
        require(msg.sender == blockballContractAddress);
        tokenPlayers[tokenCount] = players;
        tokenSeed[tokenCount] = seed;
        
        uint256 trophyData = uint256(uint160(userAddress)) << 96;
        trophyData |= (scoreBlue & 0xFFFFFFFF) << 64;
        trophyData |= (scoreRed & 0xFFFFFFFF) << 32;
        trophyData |= tournamentDate & 0xFFFFFFFF;
        tokenData[tokenCount] = trophyData;

        _mint(userAddress, tokenCount);
        trophyId = tokenCount;
        tokenCount++;
    }


    struct ExtensibleString {
        uint256 length;
        string fullString;
    }

    // Appends a string to another in a gas efficient manner
    function _appendString(ExtensibleString memory originalString, string memory appendedString) internal pure returns (uint256 newLength) {
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
    
    uint256 constant TOURNAMENT_MATCH_ROUNDS = 30;

    // Append a voxel to an SVG string
    function _appendVoxel(ExtensibleString memory voxelString, uint256 x, uint256 y, uint256 z, uint256 c, uint256 id, string memory _tokenHash) internal pure {
        
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

    function tokenSVG(uint256 _tokenId) public view returns (string memory svgStringFullString, uint256 svgStringLength, string[8] memory traitStrings) {
        ExtensibleString memory svgString;
        bytes memory svgBytes = new bytes(10000+188*400+20*400 + 0 + 40*400 + 0 + 100*400);
        svgString.length = 0;
        svgString.fullString = string(svgBytes);

        if (true) {
            uint256 trophyData = tokenData[_tokenId];
            traitStrings[0] = Strings.toHexString(trophyData >> 96, 20); // winnerAddress
            traitStrings[1] = Strings.toString(trophyData & 0xFFFFFFFF); // tournamentDate
            traitStrings[3] = Strings.toString((trophyData >> 64) & 0xFFFFFFFF); // scoreBlue
            traitStrings[4] = Strings.toString((trophyData >> 32) & 0xFFFFFFFF); // scoreRed
        }

        uint256[128] memory palette;
        uint256 paletteLength = 0;
        paletteLength = _addPaletteColor(palette, paletteLength, 0xFFFFFF); // [0] Ignored as it is used to represent the empty voxel
        if (true) {
            uint256 seed = uint256(tokenSeed[_tokenId]);
            uint256 trophyType = seed % 6;
            
            // 1) Ice, 2) Nature, 3) Sand, 4) Urban, 5) Night, 6) Ruby
            if (trophyType == 0) {
                // Ice
                traitStrings[2] = "Ice";
                paletteLength = _addPaletteColor(palette, paletteLength, 0xE0F8FF); // [1] Base
                paletteLength = _addPaletteColor(palette, paletteLength, 0xC2EFF6); // [2] Frame In
                paletteLength = _addPaletteColor(palette, paletteLength, 0xA3DBE7); // [3] Frame Out
                paletteLength = _addPaletteColor(palette, paletteLength, 0xFFFFFF); // [4] Pitch
                paletteLength = _addPaletteColor(palette, paletteLength, 0xD7E7EC); // [5] Lines
                paletteLength = _addPaletteColor(palette, paletteLength, 0xBAE7EC); // [6] Goal
                paletteLength = _addPaletteColor(palette, paletteLength, 0x0C1DA3); // [7] Blue
                paletteLength = _addPaletteColor(palette, paletteLength, 0xFF4B14); // [8] Red
                paletteLength = _addPaletteColor(palette, paletteLength, 0x66F10A); // [9] Ball
            } else {
                if (trophyType == 1) {
                    // Nature
                    traitStrings[2] = "Nature";
                    paletteLength = _addPaletteColor(palette, paletteLength, 0x188B11); // [1] Base
                    paletteLength = _addPaletteColor(palette, paletteLength, 0x046B15); // [2] Frame In
                    paletteLength = _addPaletteColor(palette, paletteLength, 0x0A4E0D); // [3] Frame Out
                    paletteLength = _addPaletteColor(palette, paletteLength, 0xD9C58E); // [4] Pitch
                    paletteLength = _addPaletteColor(palette, paletteLength, 0xCFAF78); // [5] Lines
                    paletteLength = _addPaletteColor(palette, paletteLength, 0xAD905F); // [6] Goal
                    paletteLength = _addPaletteColor(palette, paletteLength, 0x248DCA); // [7] Blue
                    paletteLength = _addPaletteColor(palette, paletteLength, 0xA81717); // [8] Red
                    paletteLength = _addPaletteColor(palette, paletteLength, 0xEFDE23); // [9] Ball
                } else {
                    if (trophyType == 2) {
                        // Sand
                        traitStrings[2] = "Sand";
                        paletteLength = _addPaletteColor(palette, paletteLength, 0xDEA647); // [1] Base
                        paletteLength = _addPaletteColor(palette, paletteLength, 0x9E7620); // [2] Frame In
                        paletteLength = _addPaletteColor(palette, paletteLength, 0x6D4F1C); // [3] Frame Out
                        paletteLength = _addPaletteColor(palette, paletteLength, 0xA9CDD4); // [4] Pitch
                        paletteLength = _addPaletteColor(palette, paletteLength, 0xCCFBFD); // [5] Lines
                        paletteLength = _addPaletteColor(palette, paletteLength, 0x7CBCCD); // [6] Goal
                        paletteLength = _addPaletteColor(palette, paletteLength, 0x21449C); // [7] Blue
                        paletteLength = _addPaletteColor(palette, paletteLength, 0x8B1114); // [8] Red
                        paletteLength = _addPaletteColor(palette, paletteLength, 0xFFF834); // [9] Ball
                    } else {
                        if (trophyType == 3) {
                            // Urban
                            traitStrings[2] = "Urban";
                            paletteLength = _addPaletteColor(palette, paletteLength, 0x868E99); // [1] Base
                            paletteLength = _addPaletteColor(palette, paletteLength, 0x65717F); // [2] Frame In
                            paletteLength = _addPaletteColor(palette, paletteLength, 0x444A55); // [3] Frame Out
                            paletteLength = _addPaletteColor(palette, paletteLength, 0xDBA74F); // [4] Pitch
                            paletteLength = _addPaletteColor(palette, paletteLength, 0xC09245); // [5] Lines
                            paletteLength = _addPaletteColor(palette, paletteLength, 0x9C7636); // [6] Goal
                            paletteLength = _addPaletteColor(palette, paletteLength, 0x3B6ED4); // [7] Blue
                            paletteLength = _addPaletteColor(palette, paletteLength, 0xE70808); // [8] Red
                            paletteLength = _addPaletteColor(palette, paletteLength, 0xFFF04F); // [9] Ball
                        } else {
                            if (trophyType == 4) {
                                // Night
                                traitStrings[2] = "Night";
                                paletteLength = _addPaletteColor(palette, paletteLength, 0x330099); // [1] Base
                                paletteLength = _addPaletteColor(palette, paletteLength, 0x4A21D1); // [2] Frame In
                                paletteLength = _addPaletteColor(palette, paletteLength, 0x5943FF); // [3] Frame Out
                                paletteLength = _addPaletteColor(palette, paletteLength, 0x111111); // [4] Pitch
                                paletteLength = _addPaletteColor(palette, paletteLength, 0x241F22); // [5] Lines
                                paletteLength = _addPaletteColor(palette, paletteLength, 0x4B3C49); // [6] Goal
                                paletteLength = _addPaletteColor(palette, paletteLength, 0x78C5E2); // [7] Blue
                                paletteLength = _addPaletteColor(palette, paletteLength, 0xFF5B9A); // [8] Red
                                paletteLength = _addPaletteColor(palette, paletteLength, 0xFFBF00); // [9] Ball
                            } else {
                                // Pink
                                traitStrings[2] = "Ruby";
                                paletteLength = _addPaletteColor(palette, paletteLength, 0xDE345B); // [1] Base
                                paletteLength = _addPaletteColor(palette, paletteLength, 0xB7164B); // [2] Frame In
                                paletteLength = _addPaletteColor(palette, paletteLength, 0x610534); // [3] Frame Out
                                paletteLength = _addPaletteColor(palette, paletteLength, 0xE7C7A7); // [4] Pitch
                                paletteLength = _addPaletteColor(palette, paletteLength, 0xD4B08D); // [5] Lines
                                paletteLength = _addPaletteColor(palette, paletteLength, 0xA18B65); // [6] Goal
                                paletteLength = _addPaletteColor(palette, paletteLength, 0x59C0EC); // [7] Blue
                                paletteLength = _addPaletteColor(palette, paletteLength, 0xF84B06); // [8] Red
                                paletteLength = _addPaletteColor(palette, paletteLength, 0xF4E00A); // [9] Ball
                            }
                        }
                    }
                }
            }
        }

        _appendString(svgString,
                "<svg width='600' height='600' viewBox='3896180 4800000 4800000 4800000' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'>\n" 
        );
        
        string memory tokenHash = Strings.toHexString(_tokenId, 4);

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

        if (true) {
            // Coordinate order:   right->left   backward->forward   downward->upward   color
            uint256 minc = 25;
            uint256 maxc = 47;
            
            // Outer edges
            for (uint256 minE = minc; minE <= minc + 3; minE++) {
                uint256 maxE = (minc + maxc) - minE;
                uint256 frameColour = 4 - (minE - minc);
                if (minE > minc) {
                    for (uint256 i = minE; i <= maxE; i++) {
                        _appendVoxel(svgString, i, minE, maxE, frameColour, 0, tokenHash);
                        _appendVoxel(svgString, i, maxE, minE, frameColour, 0, tokenHash);
                        
                        _appendVoxel(svgString, minE, i, maxE, frameColour, 0, tokenHash);
                        _appendVoxel(svgString, maxE, i, minE, frameColour, 0, tokenHash);
                        
                        _appendVoxel(svgString, maxE, minE, i, frameColour, 0, tokenHash);
                        _appendVoxel(svgString, minE, maxE, i, frameColour, 0, tokenHash);
                    }
                }
            }
            
            // Faces
            for (uint256 i = minc + 4; i <= maxc - 4; i++) { // 29 to 43
                for (uint256 j = minc + 4; j <= maxc - 4; j++) { // 29 to 43
                    if ((j == 36) || ((i >= 35 && i <= 37) && (j >= 35 && j <= 37))) {
                            _appendVoxel(svgString, j, i, maxc - 4, 5, 0, tokenHash); // Top face (play area)
                    } else {
                            if (((i == 39 || i == 33) && (j <= 33 || j >= 39)) || ((j == 33 || j == 39) && (i >= 33 && i <= 39))) { // Goal rect sides || Goal rect centers
                                    _appendVoxel(svgString, j, i, maxc - 4, 5, 0, tokenHash); // Top face (play area)
                            } else {
                                    _appendVoxel(svgString, j, i, maxc - 4, 4, 0, tokenHash); // Top face (play area)
                            }
                    }
                    if (i < maxc - 4) {
                        _appendVoxel(svgString, maxc - 3, j, i, 1, 0, tokenHash); // Left face
                        _appendVoxel(svgString, j, maxc - 3, i, 1, 0, tokenHash); // Forward face
                    } else {
                        _appendVoxel(svgString, maxc - 3, j, i, 1, 0, tokenHash); // Left face
                        _appendVoxel(svgString, j, maxc - 3, i, 1, 0, tokenHash); // Forward face
                    }
                }
            }

            // Left goal - previous position to prevent overwriting the uppermost edge of the bounding block

            // Inner edges
            for (uint256 i = minc + 3; i <= maxc - 4; i++) {
                _appendVoxel(svgString, maxc - 3, maxc - 3, i, 1, 0, tokenHash); // Edge downwards
            }
            // Right goal
            _appendVoxel(svgString, 29, 34, 44, 6, 0, tokenHash);
            _appendVoxel(svgString, 29, 34, 45, 6, 0, tokenHash);
            
            _appendVoxel(svgString, 29, 35, 45, 6, 0, tokenHash);
            _appendVoxel(svgString, 29, 36, 45, 6, 0, tokenHash);
            _appendVoxel(svgString, 29, 37, 45, 6, 0, tokenHash);
            
            _appendVoxel(svgString, 29, 38, 44, 6, 0, tokenHash);
            _appendVoxel(svgString, 29, 38, 45, 6, 0, tokenHash);

            // Players
            // NOTE: Order needs to be correct, animations do not change z-value
            _appendString(svgString, "<g id='p4'>\n");
            _appendVoxel(svgString, 31, 34, 44, 8, 0, tokenHash);
            _appendString(svgString, "</g>\n<g id='p5'>\n");
            _appendVoxel(svgString, 34, 41, 44, 8, 0, tokenHash);
            _appendString(svgString, "</g>\n<g id='p6'>\n");
            _appendVoxel(svgString, 34, 37, 44, 8, 0, tokenHash);
            _appendString(svgString, "</g>\n<g id='p7'>\n");
            _appendVoxel(svgString, 34, 32, 44, 8, 0, tokenHash);
            
            _appendString(svgString, "</g>\n<g id='p0'>\n");
            _appendVoxel(svgString, 41, 34, 44, 7, 0, tokenHash);
            _appendString(svgString, "</g>\n<g id='p1'>\n");
            _appendVoxel(svgString, 38, 30, 44, 7, 0, tokenHash);
            _appendString(svgString, "</g>\n<g id='p2'>\n");
            _appendVoxel(svgString, 38, 37, 44, 7, 0, tokenHash);
            _appendString(svgString, "</g>\n<g id='p3'>\n");
            _appendVoxel(svgString, 38, 43, 44, 7, 0, tokenHash);
            _appendString(svgString, "</g>\n<g id='b'>\n");
            
            // Ball
            _appendVoxel(svgString, 41, 34, 45, 9, 0, tokenHash);
            _appendString(svgString, "</g>\n");

            // Left goal
            _appendVoxel(svgString, 43, 34, 44, 6, 0, tokenHash);
            _appendVoxel(svgString, 43, 38, 44, 6, 0, tokenHash);

            _appendVoxel(svgString, 43, 34, 45, 6, 0, tokenHash);
            _appendVoxel(svgString, 43, 35, 45, 6, 0, tokenHash);
            _appendVoxel(svgString, 43, 36, 45, 6, 0, tokenHash);
            _appendVoxel(svgString, 43, 37, 45, 6, 0, tokenHash);
            _appendVoxel(svgString, 43, 38, 45, 6, 0, tokenHash);
        }



        // Replay Blockball game
        uint256[] memory states;
        
        states = BlockballReplay(blockballContractAddress).play(TOURNAMENT_MATCH_ROUNDS, tokenSeed[_tokenId], tokenPlayers[_tokenId], true);

        // Movements
        // -- Translating voxel movement to SVG coordinates
        // 1 forwards (rightwards on the pitch): 86603,50000
        // 1 rightwards (forwards on the pitch): 86603,-50000

        // -- Translating pitch grid movements to voxel movements
        // 1 forwards on the pitch: 3 voxel steps, always
        // 1 sideways on the pitch: 5 voxel steps if not crossing middle, 6 if crossing
        // ^ crossing happens if:
        //  - p0/p1, p4/p5 goes in or out of right side
        //  - p2/p3, p6/p7 goes in or out of left side

        //  - [7] -
        // [4][5][6]
        // [1][2][3]
        //  - [0] -
        
        if (true) {
                int256[8] memory totalXs = [int256(0), 0, 0, 0, 0, 0, 0, 0];
                int256[8] memory totalYs = [int256(0), 0, 0, 0, 0, 0, 0, 0];
                for (uint256 ir=0; ir<TOURNAMENT_MATCH_ROUNDS; ir++) {
                        for (uint256 jp=0; jp<8; jp++) {
                                _appendString(svgString, "<animateMotion xlink:href='#p");
                                _appendString(svgString, Strings.toString(jp));
                                _appendString(svgString, "' dur='0.5s' begin='");
                                _appendString(svgString, Strings.toString(START_TIME + ir));
                                _appendString(svgString, "s' fill='freeze' path='m ");

                                if (totalXs[jp] >= 0) {
                                        _appendString(svgString, Strings.toString(uint256(totalXs[jp])));
                                } else {
                                        _appendString(svgString, "-");
                                        _appendString(svgString, Strings.toString(uint256(-totalXs[jp])));
                                }
                                _appendString(svgString, ",");
                                if (totalYs[jp] >= 0) {
                                        _appendString(svgString, Strings.toString(uint256(totalYs[jp])));
                                } else {
                                        _appendString(svgString, "-");
                                        _appendString(svgString, Strings.toString(uint256(-totalYs[jp])));
                                }

                                int256 x = 0;
                                int256 y = 0;

                                if (true) {
                                        uint256 oldPosition;
                                        if (ir > 0) {
                                                oldPosition = states[12 * (ir - 1) + 4 + jp];
                                        } else {
                                                if (jp < 4) {
                                                        oldPosition = jp;
                                                } else {
                                                        oldPosition = 11 - jp;
                                                }
                                        }
                                        uint256 newPosition = states[12 * ir + 4 + jp];

                                        int256 pitchForwards = 0;
                                        int256 pitchRightwards = 0;

                                        pitchForwards = (int256(newPosition) + 2) / 3 - (int256(oldPosition) + 2) / 3;
                                        uint256 oldRw = (oldPosition + (oldPosition + 5) / 6 + 1) % 3;
                                        uint256 newRw = (newPosition + (newPosition + 5) / 6 + 1) % 3;
                                        pitchRightwards = int256(newRw) - int256(oldRw);

                                        int256 crossedMiddle = 0;
                                        if (oldRw != newRw) {
                                                uint256 otherSide = 2 - (((jp % 4) / 2) * 2);
                                                if (oldRw == otherSide || newRw == otherSide) {
                                                        if (pitchRightwards > 0) {
                                                                crossedMiddle = 1;
                                                        } else {
                                                                crossedMiddle = -1;
                                                        }
                                                }
                                        }
                                        x = pitchForwards * 3 * 86603;
                                        y = pitchForwards * 3 * -50000;
                                        x += (pitchRightwards * 5 + crossedMiddle) * 86603;
                                        y += (pitchRightwards * 5 + crossedMiddle) * 50000;
                                }

                                _appendString(svgString, " ");
                                if (x >= 0) {
                                        _appendString(svgString, Strings.toString(uint256(x)));
                                } else {
                                        _appendString(svgString, "-");
                                        _appendString(svgString, Strings.toString(uint256(-x)));
                                }
                                _appendString(svgString, ",");
                                if (y >= 0) {
                                        _appendString(svgString, Strings.toString(uint256(y)));
                                } else {
                                        _appendString(svgString, "-");
                                        _appendString(svgString, Strings.toString(uint256(-y)));
                                }

                                _appendString(svgString, "'/>\n");

                                totalXs[jp] += x;
                                totalYs[jp] += y;
                        }
                }
        }



        // Ball
        
        int256 totalX = 0;
        int256 totalY = 0;
        
        int256 x = 0;
        int256 y = 0;

        for (uint256 ir=0; ir<TOURNAMENT_MATCH_ROUNDS; ir++) {
                // Checking for Tackle or Intercept
                bool tackled = false;
                if (ir > 0) {
                    uint256 prevCurrent = states[(ir - 1) * 12 + 3];
                    uint256 current = states[ir * 12 + 3];
                    if ((prevCurrent / 4) != (current / 4)) {
                        if ((states[(ir - 1) * 12 + 1] + states[(ir - 1) * 12 + 2]) == (states[ir * 12 + 1] + states[ir * 12 + 2])) {
                            // It was not a goal
                            if (states[(ir - 1) * 12 + 4 + prevCurrent] == states[(ir - 1) * 12 + 4 + current]) {
                                // Players were in the same position
                                
                                // ------------------------------------------------------------------------------------------------------------------------------
                                _appendString(svgString, "<animateMotion xlink:href='#b' dur='0.25s' begin='");
                                _appendString(svgString, Strings.toString(START_TIME + ir - 1));
                                _appendString(svgString, ".75s' fill='freeze' path='m "); 
                                if (totalX >= 0) {
                                        _appendString(svgString, Strings.toString(uint256(totalX)));
                                } else {
                                        _appendString(svgString, "-");
                                        _appendString(svgString, Strings.toString(uint256(-totalX)));
                                }
                                _appendString(svgString, ",");
                                if (totalY >= 0) {
                                        _appendString(svgString, Strings.toString(uint256(totalY)));
                                } else {
                                        _appendString(svgString, "-");
                                        _appendString(svgString, Strings.toString(uint256(-totalY)));
                                }

                                x = ((int256(current) / 4) * 2 - 1) * 86603;
                                y = ((int256(current) / 4) * 2 - 1) * -50000;

                                if (true) {
                                    int256 rightwardsOffset = (int256(current) % 4) - (int256(prevCurrent) % 4);
                                    uint256 currentPos = states[(ir - 1) * 12 + 4 + current];
                                    if (((currentPos + (currentPos + 5) / 6 + 1) % 3) == 1) {
                                        rightwardsOffset += (((int256(current) % 4) / 2) - ((int256(prevCurrent) % 4) / 2));

                                    }
                                    x += rightwardsOffset * 86603;
                                    y += rightwardsOffset * 50000;
                                }

                                _appendString(svgString, " ");
                                if (x >= 0) {
                                        _appendString(svgString, Strings.toString(uint256(x)));
                                } else {
                                        _appendString(svgString, "-");
                                        _appendString(svgString, Strings.toString(uint256(-x)));
                                }
                                _appendString(svgString, ",");
                                if (y >= 0) {
                                        _appendString(svgString, Strings.toString(uint256(y)));
                                } else {
                                        _appendString(svgString, "-");
                                        _appendString(svgString, Strings.toString(uint256(-y)));
                                }

                                _appendString(svgString, "'/>\n");

                                totalX += x;
                                totalY += y;
                                // ------------------------------------------------------------------------------------------------------------------------------
                                tackled = true;
                            }
                        }
                    }
                }
                
                _appendString(svgString, "<animateMotion xlink:href='#b' dur='0.5s' begin='");
                _appendString(svgString, Strings.toString(START_TIME + ir));
                _appendString(svgString, "s' fill='freeze' path='m ");
                if (totalX >= 0) {
                        _appendString(svgString, Strings.toString(uint256(totalX)));
                } else {
                        _appendString(svgString, "-");
                        _appendString(svgString, Strings.toString(uint256(-totalX)));
                }
                _appendString(svgString, ",");
                if (totalY >= 0) {
                        _appendString(svgString, Strings.toString(uint256(totalY)));
                } else {
                        _appendString(svgString, "-");
                        _appendString(svgString, Strings.toString(uint256(-totalY)));
                }

                if (true) {
                        uint256 newPlayer = states[ir * 12 + 3];
                        uint256 newPosition = states[ir * 12 + 4 + newPlayer];
                        uint256 oldPlayer;
                        uint256 oldPosition;
                        if (tackled) {
                            oldPlayer = newPlayer;
                            oldPosition = states[(ir - 1) * 12 + 4 + oldPlayer];
                        } else {
                            if (ir > 0) {
                                    oldPlayer = states[(ir - 1) * 12 + 3];
                                    oldPosition = states[(ir - 1) * 12 + 4 + oldPlayer];
                            } else {
                                    oldPlayer = 0;
                                    oldPosition = 0;
                            }
                        }

                        int256 pitchForwards = 0;
                        int256 pitchRightwards = 0;
                        pitchForwards = (int256(newPosition) + 2) / 3 - (int256(oldPosition) + 2) / 3;
                        int256 crossedMiddle = 0;
                        if (true) {
                                uint256 oldRw = (oldPosition + (oldPosition + 5) / 6 + 1) % 3;
                                uint256 newRw = (newPosition + (newPosition + 5) / 6 + 1) % 3;

                                pitchRightwards = int256(newRw) - int256(oldRw);

                                // 0 for left side of the pitch, 1 for right
                                if (oldRw == 1) {
                                        oldRw = (oldPlayer % 4) / 2;
                                } else {
                                        oldRw = oldRw / 2;
                                }
                                if (newRw == 1) {
                                        newRw = (newPlayer % 4) / 2;
                                } else {
                                        newRw = newRw / 2;
                                }
                                crossedMiddle = int256(newRw) - int256(oldRw);
                        }
                        int256 forwardsOffset = (int256(newPlayer) / 4) - (int256(oldPlayer) / 4);
                        crossedMiddle += (int256(newPlayer) % 4) - (int256(oldPlayer) % 4);

                        x = (pitchForwards * 3 + forwardsOffset) * 86603;
                        y = (pitchForwards * 3 + forwardsOffset) * -50000;
                        x += (pitchRightwards * 5 + crossedMiddle) * 86603;
                        y += (pitchRightwards * 5 + crossedMiddle) * 50000;

                        // Need to account for offset based on possessive player's id
                }

                _appendString(svgString, " ");
                if (x >= 0) {
                        _appendString(svgString, Strings.toString(uint256(x)));
                } else {
                        _appendString(svgString, "-");
                        _appendString(svgString, Strings.toString(uint256(-x)));
                }
                _appendString(svgString, ",");
                if (y >= 0) {
                        _appendString(svgString, Strings.toString(uint256(y)));
                } else {
                        _appendString(svgString, "-");
                        _appendString(svgString, Strings.toString(uint256(-y)));
                }

                _appendString(svgString, "'/>\n");

                totalX += x;
                totalY += y;

                // Goal
                if (ir > 0) {
                    if ((states[ir * 12 + 1] > states[(ir - 1) * 12 + 1]) || (states[ir * 12 + 2] > states[(ir - 1) * 12 + 2])) {
                        for (uint256 j = 0; j < 2; j++) {
                            _appendString(svgString, "<animateMotion xlink:href='#b' dur='0.25s' begin='");
                            _appendString(svgString, Strings.toString(START_TIME + ir));
                            if (j == 0) {
                                _appendString(svgString, ".5s' fill='freeze' path='m ");
                            } else {
                                _appendString(svgString, ".75s' fill='freeze' path='m "); 
                            }
                            if (totalX >= 0) {
                                    _appendString(svgString, Strings.toString(uint256(totalX)));
                            } else {
                                    _appendString(svgString, "-");
                                    _appendString(svgString, Strings.toString(uint256(-totalX)));
                            }
                            _appendString(svgString, ",");
                            if (totalY >= 0) {
                                    _appendString(svgString, Strings.toString(uint256(totalY)));
                            } else {
                                    _appendString(svgString, "-");
                                    _appendString(svgString, Strings.toString(uint256(-totalY)));
                            }

                            if (states[ir * 12 + 1] > states[(ir - 1) * 12 + 1]) {
                                if (j == 1) { x *= -1; y *= -1; }
                            } else {
                                if (j == 0) { x *= -1; y *= -1; }
                            }

                            _appendString(svgString, " ");
                            if (x >= 0) {
                                    _appendString(svgString, Strings.toString(uint256(x)));
                            } else {
                                    _appendString(svgString, "-");
                                    _appendString(svgString, Strings.toString(uint256(-x)));
                            }
                            _appendString(svgString, ",");
                            if (y >= 0) {
                                    _appendString(svgString, Strings.toString(uint256(y)));
                            } else {
                                    _appendString(svgString, "-");
                                    _appendString(svgString, Strings.toString(uint256(-y)));
                            }

                            _appendString(svgString, "'/>\n");

                            totalX += x;
                            totalY += y;
                        }
                    }
                }
        }



        // Scores
        // Coordinate order:   right->left   backward->forward   downward->upward   color
        if (true) {
                uint256 score = 0;
                for (uint256 ir=0; ir < TOURNAMENT_MATCH_ROUNDS; ir++) {
                        if (states[ir * 12 + 1] > score) {
                                _appendString(svgString, "<g id='sb");
                                _appendString(svgString, Strings.toString(states[ir * 12 + 1]));
                                _appendString(svgString, "'>\n");
                                _appendVoxel(svgString, 45, 28, 28 + states[ir * 12 + 1] - 1, 7, 0, tokenHash); // Blue
                                _appendString(svgString, "</g>\n");

                                // Appear
                                _appendString(svgString, "<animate xlink:href='#sb");
                                _appendString(svgString, Strings.toString(states[ir * 12 + 1]));
                                _appendString(svgString, "' attributeName='opacity' values='0;0;1' dur='");
                                _appendString(svgString, Strings.toString(START_TIME + ir));
                                _appendString(svgString, ".5s' begin='0s' keyTimes='0;0.9999;1.0' repeatCount='1'/>\n");

                                score = states[ir * 12 + 1];
                        }
                }
                score = 0;
                for (uint256 ir=0; ir < TOURNAMENT_MATCH_ROUNDS; ir++) {
                        if (states[ir * 12 + 2] > score) {
                                _appendString(svgString, "<g id='sr");
                                _appendString(svgString, Strings.toString(states[ir * 12 + 2]));
                                _appendString(svgString, "'>\n");
                                _appendVoxel(svgString, 28, 45, 28 + states[ir * 12 + 2] - 1, 8, 0, tokenHash); // Red
                                _appendString(svgString, "</g>\n");
                                
                                // Appear
                                _appendString(svgString, "<animate xlink:href='#sr");
                                _appendString(svgString, Strings.toString(states[ir * 12 + 2]));
                                _appendString(svgString, "' attributeName='opacity' values='0;0;1' dur='");
                                _appendString(svgString, Strings.toString(START_TIME + ir));
                                _appendString(svgString, ".5s' begin='0s' keyTimes='0;0.9999;1.0' repeatCount='1'/>\n");
                                
                                score = states[ir * 12 + 2];
                        }
                }

        }

        _appendString(svgString,
                '</svg>\n'
        );

        svgStringFullString = svgString.fullString;
        svgStringLength = svgString.length;
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        return UtilityFormattingForBlocktrophies(utilityFormattingContractAddress).formatURI(_tokenId, tokenData[_tokenId]);
    }
}
