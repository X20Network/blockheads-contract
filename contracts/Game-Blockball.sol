// SPDX-License-Identifier: All Rights Reserved
// Copyright 2023 Blockheads.network. All Rights Reserved.
pragma solidity >=0.8.0;

abstract contract BlockheadsForBlockball {
    function ownerOf(uint256 tokenId) public view virtual returns (address);
    function tokenData(uint256 tokenId) public view virtual returns (uint256 data);
    function freezeMyBlockhead(address userAddress, uint256 tokenId) public virtual returns (bool);
    function unfreezeMyBlockhead(address userAddress, uint256 tokenId) public virtual returns (bool);
    function burnMyBlockhead(address userAddress, uint256 tokenId) public virtual returns (bool);
    function getTeam(uint256 tokenId) public view virtual returns (uint256 teamId);
    function getLastPlayedTournamentId(uint256 tokenId) public view virtual returns (uint256 tournamentId);
    function getGasRefundPrice() public virtual returns (uint256 price);
    function requestGasRefund(uint256 _gasUsed) external virtual returns (uint256 price);
    function updateData(uint256 blockId, uint256 newData) public virtual;
    function mintPrizes(address gold, address silver, address bronze) external virtual;
    function realOwnerOf (uint256 tokenId) public view virtual returns (address);
}
abstract contract BlockletsForBlockball {
    function ownerOf(uint256 tokenId) public view virtual returns (address);
    function tokenData(uint256 tokenId) public view virtual returns (uint256 data);
    function awardBlocklet(address userAddress, uint256 tokenData) public virtual returns (uint256 blockletId);
    function updateData(uint256 blockId, uint256 newData) public virtual;
}
abstract contract BlocktrophiesForBlockball {
    function awardTrophy(address userAddress, uint32[8] memory players, bytes32 seed, uint256 scoreBlue, uint256 scoreRed, uint256 tournamentDate) public virtual returns (uint256 trophyId);
}

contract Blockball {
    struct Team {
        uint32[6] players;
    }
    
    mapping (uint256 => uint256) playerList;
    uint256 public playerCount = 0;
    mapping (uint256 => Team) teams;
    mapping (address => Team[]) userTeams;
    uint256 public teamCount = 0;

    mapping (address => uint256) revealPayment;

    address[] revealsStack0;
    address[] revealsStack1;
    mapping (address => bytes32) addressToSalt;

    uint256 tournamentId;
    uint256 lastTournamentTime;
    bool tournamentInProgress;

    uint256 pointerBlue;
    uint256 pointerRed;
    bool blueCorrect;

    bytes32 random;

    uint256 strategyTrainingCost; // If 0, the functionality is disabled

    mapping (address => bytes32) teamCommitments;
    mapping (address => uint256) committedBlockheadId;
    mapping (address => uint256) committedTournamentId;

    mapping (uint256 => uint256) playerTeam;
    mapping (uint256 => uint256) playerLastPlayedTournamentId;
    mapping (uint256 => uint256) playerLastRandomizedTournamentId;

    address owner;
    address public blockheadsContractAddress;
    address public blockballContractAddress;
    address public blockmintingContractAddress;
    address public blockletsContractAddress;
    address public blocktrophiesContractAddress;
    address public utilityFormattingContractAddress;
    bool awardedPrizes;
    
    constructor(address blockheads) {
        owner = msg.sender;
        blockheadsContractAddress = blockheads;
        random = keccak256(abi.encodePacked("Blockball"));
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
    
    function addPlayer(uint256 x) public {
        playerList[playerCount] = x;
        playerCount += 1;
    }
    
    function addTeam(uint32 p1, uint32 p2, uint32 p3, uint32 p4) public {
        teams[teamCount] = Team([p1, p2, p3, p4, 0, 0]);
        teamCount += 1;
    }
    
    uint256 constant BLOCKHEADS_COUNT = 1992;

    uint256 constant NEIGHBOURHOOD_MATRIX = 0xf0e8f4b24d2f170f;
    uint256 constant NEIGHBOURHOOD_LIST = 0x1ac1ebfa21e9190ac81100d1;
    uint256 constant DISTANCE_MATRIX = 0x15ab466a519a64a69a19a645a591ea54;
    uint256 constant NOTNEIGHBOURHOOD_MASK = 0xf0000000_e8000000_d0000000_b2000000_4d000000_0b000000_17000000_0f000000;
    uint256 constant BIT_MASK_1R_32_UNMERGE = 0x80000000_80000000_80000000_80000000_80000000_80000000_80000000_80000000;
    uint256 constant BIT_MARK_3_32 = 0x00000007_00000006_00000005_00000004_00000003_00000002_00000001_00000000;
    uint256 constant BIT_MASK_128_LARGE = 0xffffffffffffffffffffffffffffffff00000000000000000000000000000000;
    uint256 constant BIT_MASK_128_SMALL = 0xffffffffffffffffffffffffffffffff;
    uint256 constant BIT_MASK_64_SMALL = 0xffffffffffffffff;
    uint256 constant BIT_MASK_32 = 0xffffffff;
    uint256 constant DISTANCE_LISTS_MERGED = 0x01112223_10121222_11012122_12102212_21220121_22121011_22212101_32221110;
    uint256 constant BIT_MASK_4_32_MERGED = 0x0000000F_0000000F_0000000F_0000000F_0000000F_0000000F_0000000F_0000000F;

    uint256 constant SCORE_FACTOR = 1000000;
    uint256 constant SCORE_RANDOM_COMPONENT = 1000000;

    uint256 constant BREEDING_MUTATION_RARITY_EXPONENT = 5;
    uint256 constant MAX_UINT256 = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    uint256 constant TEAM_COMMITMENT_REVEAL_PERIOD = 12 hours;

    uint256 constant TOURNAMENT_FREQUENCY = 1 days;

    uint256 constant TOURNAMENT_MATCH_ROUNDS = 30;

    uint256 constant TOURNAMENT_TOTAL_DAYS = 180;

    event Section(string s);
    event Tournament(uint256 tournamentId);
    event Positions(uint256 p0, uint256 p1, uint256 p2, uint256 p3, uint256 p4, uint256 p5, uint256 p6, uint256 p7);
    event State(uint256 r, uint256 s0, uint256 s1, uint256 c, uint256 p0, uint256 p1, uint256 p2, uint256 p3, uint256 p4, uint256 p5, uint256 p6, uint256 p7); // Round, Score 0, Score 1, Current ball player, Player positions 0-7
    event StateExcess(uint256 dp, uint256 dr);
    event Ball(string action);
    event LogBytes(bytes b);
    event LogBytes32(bytes32 b);
    event Match(address indexed userB, address indexed userR, uint256 scoreB, uint256 scoreR, uint32[8] players, uint256 blocktrophyIndex, uint256 blockletIndex, bytes32 randomSeed);



    function awardPrizes() external {
        require(awardedPrizes == false);
        uint256 p0score = 0;
        uint256 p1score = 0;
        uint256 p2score = 0;
        address p0address;
        address p1address;
        address p2address;
        for (uint256 i=0; i < BLOCKHEADS_COUNT; i++) {
            uint256 data = BlockheadsForBlockball(blockheadsContractAddress).tokenData(i);
            uint256 score = (data >> (128 + 40 + 24)) & 0xff; // winCount
            score = score << 16;
            score += 0xffff - (data >> (128 + 40) & 0xffff); // Rarity inverted

            if (score > p2score) {
                p2score = score;
                p2address = BlockheadsForBlockball(blockheadsContractAddress).ownerOf(i);

                if (score > p1score) {
                    p2score = p1score;
                    p2address = p1address;

                    p1score = score;
                    p1address = BlockheadsForBlockball(blockheadsContractAddress).ownerOf(i);

                    if (score > p0score) {
                        p1score = p0score;
                        p1address = p0address;

                        p0score = score;
                        p0address = BlockheadsForBlockball(blockheadsContractAddress).ownerOf(i);
                    }
                }
            }
        }
        BlockheadsForBlockball(blockheadsContractAddress).mintPrizes(p0address, p1address, p2address);
        awardedPrizes = true;
    }

    function setStrategyTrainingCost(uint256 cost) external {
        require(msg.sender == owner);
        strategyTrainingCost = cost;
    }

    function trainStrategy(uint256 blockId, uint256 strategy) external {
        require(strategyTrainingCost > 0); // Only if enabled
        require(tournamentInProgress == false); // Tournament outcome cannot change
        require((strategy >> 44) == 0); // Strategy can only contain 44 bits
        uint256 blockData;
        if ((blockId >> 16) == 0) {
            require(BlockheadsForBlockball(blockheadsContractAddress).ownerOf(blockId) == msg.sender);
            blockData = BlockheadsForBlockball(blockheadsContractAddress).tokenData(blockId);
        } else {
            require(BlockletsForBlockball(blockletsContractAddress).ownerOf(blockId) == msg.sender);
            blockData = BlockletsForBlockball(blockletsContractAddress).tokenData(blockId);
        }

        uint256 totalBits = 0;
        uint256 strategyDifference = 0;
        for (uint256 i=0; i < 18; i++) {
            uint256 bits;
            if (i < 9) {
                bits = 3;
            } else {
                if (i < 17) {
                    bits = 2;
                } else {
                    bits = 1;
                }
            }

            uint256 mask = (1 << bits) - 1;
            uint256 original = (blockData >> (8 + totalBits)) & mask;
            uint256 updated = (strategy >> totalBits) & mask;
            if (updated >= original) {
                strategyDifference += updated - original;
            } else {
                strategyDifference += original - updated;
            }
        }

        uint256 winPoints = (blockData >> (128 + 40 + 32)) & 0xff;
        require(winPoints >= strategyDifference * strategyTrainingCost);
        uint256 winPointsMask = 0xff << (128 + 40 + 32);
        uint256 updatedPoints = winPoints - strategyDifference * strategyTrainingCost;
        require(updatedPoints <= 0xff);

        uint256 updatedData = blockData & (~winPointsMask);
        updatedData |= updatedPoints << (128 + 40 + 32);
        uint256 strategyMask = ((1 << 44) - 1) << 8;
        updatedData &= ~strategyMask;
        updatedData |= strategy;

        if ((blockId >> 16) == 0) {
            BlockheadsForBlockball(blockheadsContractAddress).updateData(blockId, updatedData);
        } else {
            BlockletsForBlockball(blockletsContractAddress).updateData(blockId, updatedData);
        }
    }



    function breed(address userAddress, uint256 _block0Id, uint256 _block1Id) internal returns (uint256 blockletId) {
        uint256 data0;
        if ((_block0Id >> 16) == 0){
            data0 = BlockheadsForBlockball(blockheadsContractAddress).tokenData(_block0Id);
        } else {
            data0 = BlockletsForBlockball(blockletsContractAddress).tokenData(_block0Id);
        }
        uint256 data1;
        if ((_block1Id >> 16) == 0){
            data0 = BlockheadsForBlockball(blockheadsContractAddress).tokenData(_block1Id);
        } else {
            data0 = BlockletsForBlockball(blockletsContractAddress).tokenData(_block1Id);
        }

        uint256 randomBitMask = uint256(_getRandomSeed());

        uint256 blockletData = (data0 & randomBitMask) | (data1 & (~randomBitMask));

        uint256 mutationBitMask = MAX_UINT256;

        for (uint256 i = 0; i < BREEDING_MUTATION_RARITY_EXPONENT; i++) {
            randomBitMask = uint256(_getRandomSeed());
            mutationBitMask = mutationBitMask & randomBitMask;
        }
        blockletData = blockletData ^ mutationBitMask;

        uint256 noValuesMask = ~(uint256(0xffffffffffff) << (128 + 40));
        blockletData = blockletData & noValuesMask;

        blockletId = BlockletsForBlockball(blockletsContractAddress).awardBlocklet(userAddress, blockletData);
    }

    function commitTeams(uint256 blockheadId, bytes32 commitmentHash) external payable {
        require(BlockheadsForBlockball(blockheadsContractAddress).ownerOf(blockheadId) == msg.sender);
        require(tournamentInProgress == false);
        require(teamCommitments[msg.sender] == 0); // NOTE: This is necessary otherwise the player may freeze extra blockheads using this twice

        revealPayment[msg.sender] += msg.value;

        teamCommitments[msg.sender] = commitmentHash;
        committedBlockheadId[msg.sender] = blockheadId;
        BlockheadsForBlockball(blockheadsContractAddress).freezeMyBlockhead(msg.sender, blockheadId);

        uint256 revealTournamentId = tournamentId + 1;
        uint256 timing = block.timestamp % TOURNAMENT_FREQUENCY;
        if (timing > TOURNAMENT_FREQUENCY / 2) {
            revealTournamentId += 1;
        }
        committedTournamentId[msg.sender] = revealTournamentId;
        if (revealTournamentId % 2 == 0) {
            revealsStack0.push(msg.sender);
        } else {
            revealsStack1.push(msg.sender);
        }
    }

    function revealTeams(address userAddress, uint32[] calldata players, bytes32 salt) external {
        require(teamCommitments[userAddress] != 0);

        require(teamCommitments[userAddress] == keccak256(abi.encodePacked(players, salt)));

        require(committedTournamentId[userAddress] == tournamentId + 1);
        uint256 timing = block.timestamp % TOURNAMENT_FREQUENCY;
        require(timing > TOURNAMENT_FREQUENCY / 2);

        while (userTeams[userAddress].length > 1) {
            Team memory removedTeam = userTeams[userAddress][userTeams[userAddress].length - 1];
            for (uint256 i = 0; i < 4; i++) {
                playerTeam[removedTeam.players[i]] = 0;
            }

            userTeams[userAddress].pop();
        }
        if (userTeams[userAddress].length == 0) {
            userTeams[userAddress].push(Team([uint32(0), 0, 0, 0, 0, 0])); // Indexing needs to start from 1
        }
        for (uint256 i = 0; i < players.length / 6; i++) {
            bool ownsAll = true;
            bool blockheadIncluded = false;
            for (uint256 j = i * 6; j < i * 6 + 4; j++) {
                if ((players[j] >> 16) == 0) {
                    ownsAll = ownsAll && ((BlockheadsForBlockball(blockheadsContractAddress).ownerOf(players[j]) == userAddress) || (BlockheadsForBlockball(blockheadsContractAddress).realOwnerOf(players[j]) == userAddress));
                    require(players[j] < BLOCKHEADS_COUNT); // Awarded Blockheads cannot play
                    blockheadIncluded = true;
                } else {
                    ownsAll = ownsAll && (BlockletsForBlockball(blockletsContractAddress).ownerOf(players[j]) == userAddress);
                }
            }
            for (uint256 j = i * 6 + 4; j < i * 6 + 6; j++) {
                require(players[j] < 4);
            }
            if (ownsAll && blockheadIncluded) {
                userTeams[userAddress].push(Team([players[i * 6], players[i * 6 + 1], players[i * 6 + 2], players[i * 6 + 3], players[i * 6 + 4], players[i * 6 + 5]]));
                for (uint256 j = 0; j < 4; j++) {
                    playerTeam[players[i * 6 + j]] = i + 1;
                }
            }
        }

        random = keccak256(abi.encodePacked(random, salt));
        addressToSalt[userAddress] = salt;

        BlockheadsForBlockball(blockheadsContractAddress).unfreezeMyBlockhead(userAddress, committedBlockheadId[userAddress]);

        teamCommitments[userAddress] = 0;

        if (revealPayment[userAddress] > 0) {
            payable(msg.sender).transfer(revealPayment[userAddress]);
            revealPayment[userAddress] = 0;
        }
    }

    function _getRevealStackLength() internal view returns (uint256) {
        if (tournamentId % 2 == 0) {
            return revealsStack0.length;
        } else {
            return revealsStack1.length;
        }
    }

    function _getRandomNumber(uint256 x) internal returns (uint256 result) {
        random = keccak256(abi.encodePacked(random, "Block"));
        result = uint256(random) % x;
    }

    function _getRandomSeed() internal returns (bytes32 result) {
        random = keccak256(abi.encodePacked(random, "Block"));
        result = random;
    }

    function processTournament(uint256 revealsLimit, uint256 stepsLimit, uint256 matchesLimit, uint256 gasRefundPriceMin, uint256 individualId) external {
        uint256 gasUsed = gasleft();
        if (gasRefundPriceMin > 0) {
            uint256 gasPriceToRefund = BlockheadsForBlockball(blockheadsContractAddress).getGasRefundPrice();
            require(gasPriceToRefund >= gasRefundPriceMin);
            require(individualId >> 128 == 0); // Cannot receive refund for processing an individual match
        }

        // ----- TOURNAMENT START -----
        if ((tournamentInProgress == false) && (((block.timestamp) / TOURNAMENT_FREQUENCY) > lastTournamentTime)) {
            require(tournamentId < TOURNAMENT_TOTAL_DAYS);
            tournamentId += 1;
            lastTournamentTime = block.timestamp / TOURNAMENT_FREQUENCY;
            tournamentInProgress = true;

            pointerBlue = _getRandomNumber(BLOCKHEADS_COUNT);
            pointerRed = (pointerBlue + 1) % BLOCKHEADS_COUNT;
            blueCorrect = false;
        }

        // ----- COMMITMENT REVEALS -----
        while ((_getRevealStackLength() > 0) && (revealsLimit > 0)) {
            address revealUser;
            if (tournamentId % 2 == 0) {
                revealUser = revealsStack0[revealsStack0.length - 1];
                revealsStack0.pop();
            } else {
                revealUser = revealsStack1[revealsStack1.length - 1];
                revealsStack1.pop();
            }
            if (teamCommitments[revealUser] != 0) {
                // User did not reveal their commitment
                teamCommitments[revealUser] = 0;
                require(BlockheadsForBlockball(blockheadsContractAddress).burnMyBlockhead(msg.sender, committedBlockheadId[revealUser]));
            } else {
                bytes32 randomPlaceholder = keccak256(abi.encodePacked(random, addressToSalt[revealUser]));
            }

            revealsLimit -= 1;
        }

        uint256 ptrRed = pointerRed;
        uint256 ptrBlue = pointerBlue;

        while ((_getRevealStackLength() == 0) && (((stepsLimit > 0) && (matchesLimit > 0)) && tournamentInProgress)) {

            // ----- BLUE POINTER -----
            Team memory pointerBlueTeam;
            address pointerBlueUser;
            if (!blueCorrect) {
                while (((stepsLimit > 0) && (matchesLimit > 0)) && ((blueCorrect == false) && (tournamentInProgress))) {
                    uint256 pointerBlueTeamId = playerTeam[ptrBlue];
                    uint256 pointerBlueLast = playerLastPlayedTournamentId[ptrBlue];
                    uint256 pointerBlueLastRandomized = playerLastRandomizedTournamentId[ptrBlue];
                    if ((pointerBlueTeamId == 0) || ((pointerBlueLast == tournamentId) || (pointerBlueLastRandomized == tournamentId && (individualId >> 128 > 0)))) {
                        ptrBlue = (ptrBlue + BLOCKHEADS_COUNT - 1) % BLOCKHEADS_COUNT;
                        stepsLimit -= 1;
                    } else {
                        bool missingBlocks = false;
                        pointerBlueUser = BlockheadsForBlockball(blockheadsContractAddress).ownerOf(ptrBlue);
                        pointerBlueTeam = userTeams[pointerBlueUser][pointerBlueTeamId];

                        for (uint256 i = 0; i < 4; i++) {
                            uint32 playerId = pointerBlueTeam.players[i];
                            if ((playerId >> 16) == 0) {
                                if (BlockheadsForBlockball(blockheadsContractAddress).ownerOf(playerId) != pointerBlueUser) {
                                    missingBlocks = true;
                                }
                            } else {
                                if (BlockletsForBlockball(blockletsContractAddress).ownerOf(playerId) != pointerBlueUser) {
                                    missingBlocks = true;
                                }
                            }
                        }
                        if (missingBlocks) {
                            ptrBlue = (ptrBlue + BLOCKHEADS_COUNT - 1) % BLOCKHEADS_COUNT;
                            stepsLimit -= 1;
                        } else {
                            // Blue pointer is correct
                            blueCorrect = true;
                            if (individualId >> 128 == 0) {
                                for (uint256 i = 0; i < 4; i++) {
                                    playerLastPlayedTournamentId[pointerBlueTeam.players[i]] = tournamentId;
                                }
                            }
                        }
                    }
                    if (ptrBlue == ptrRed) {
                        // Processing is over
                        tournamentInProgress = false;
                        emit Tournament(tournamentId);
                    }
                }
            } else {
                uint256 pointerBlueTeamId = playerTeam[ptrBlue];
                pointerBlueUser = BlockheadsForBlockball(blockheadsContractAddress).ownerOf(ptrBlue);
                pointerBlueTeam = userTeams[pointerBlueUser][pointerBlueTeamId];
            }

            if (blueCorrect) {
                // ----- RED POINTER -----
                while (((stepsLimit > 0) && (matchesLimit > 0)) && (tournamentInProgress && blueCorrect)) {
                    bool matchPlayed = false;
                    if (true) { // Extra scope to free up stack space
                        uint256 pointerRedTeamId = playerTeam[ptrRed];
                        uint256 pointerRedLast = playerLastPlayedTournamentId[ptrRed];
                        uint256 pointerRedLastRandomized = playerLastRandomizedTournamentId[ptrRed];
                        if ((pointerRedTeamId == 0) || ((pointerRedLast == tournamentId) || (pointerRedLastRandomized == tournamentId && (individualId >> 128 > 0)))) {
                            ptrRed = (ptrRed + 1) % BLOCKHEADS_COUNT;
                        } else {
                            bool missingBlocks = false;
                            address pointerRedUser = BlockheadsForBlockball(blockheadsContractAddress).ownerOf(ptrRed);
                            Team memory pointerRedTeam = userTeams[pointerRedUser][pointerRedTeamId];
                            for (uint256 i = 0; i < 4; i++) {
                                uint32 playerId = pointerRedTeam.players[i];
                                if ((playerId >> 16) == 0) {
                                    if (BlockheadsForBlockball(blockheadsContractAddress).ownerOf(playerId) != pointerRedUser) {
                                        missingBlocks = true;
                                    }
                                } else {
                                    if (BlockletsForBlockball(blockletsContractAddress).ownerOf(playerId) != pointerRedUser) {
                                        missingBlocks = true;
                                    }
                                }
                            }
                            if (missingBlocks) {
                                ptrRed = (ptrRed + 1) % BLOCKHEADS_COUNT;
                            } else {
                                // Red pointer is correct

                                if (individualId >> 128 > 0) {
                                    bool individualIncluded = false;
                                    uint256 individualBlockId = individualId & 0xffff;
                                    for(uint256 i = 0; i < 4; i++) {
                                        if (pointerBlueTeam.players[i] == individualBlockId) {
                                            individualIncluded = true;
                                        }
                                        if (pointerRedTeam.players[i] == individualBlockId) {
                                            individualIncluded = true;
                                        }
                                    }
                                }

                                if (individualId >> 128 == 0) {
                                    for (uint256 i = 0; i < 4; i++) {
                                        playerLastPlayedTournamentId[pointerRedTeam.players[i]] = tournamentId;
                                    }
                                }

                                uint32[8] memory players = [pointerBlueTeam.players[0], pointerBlueTeam.players[1], pointerBlueTeam.players[2], pointerBlueTeam.players[3], pointerRedTeam.players[0], pointerRedTeam.players[1], pointerRedTeam.players[2], pointerRedTeam.players[3]];
                                bytes32 matchRandomSeed = _getRandomSeed();
                                uint256[] memory state = play(TOURNAMENT_MATCH_ROUNDS, matchRandomSeed, players, false);

                                uint256[2] memory tokenIds;
                                if (state[1] > state[2]) {
                                    // Blue player won
                                    if (true) {
                                        tokenIds[0] = BlocktrophiesForBlockball(blocktrophiesContractAddress).awardTrophy(pointerBlueUser, players, matchRandomSeed, state[1], state[2], block.timestamp);
                                    }
                                    uint256 breeder1 = pointerBlueTeam.players[pointerBlueTeam.players[4]];
                                    uint256 breeder2 = pointerBlueTeam.players[pointerBlueTeam.players[5]];
                                    tokenIds[1] = breed(pointerBlueUser, breeder1, breeder2);

                                } else {
                                    if (state[1] < state[2]) {
                                        // Red player won
                                        if (true) {
                                            tokenIds[0]  = BlocktrophiesForBlockball(blocktrophiesContractAddress).awardTrophy(pointerRedUser, players, matchRandomSeed, state[1], state[2], block.timestamp);
                                        }
                                        tokenIds[1] = breed(pointerRedUser, pointerRedTeam.players[pointerRedTeam.players[4]], pointerRedTeam.players[pointerRedTeam.players[5]]);
                                    } else {
                                        // Draw
                                        tokenIds[0] = BlocktrophiesForBlockball(blocktrophiesContractAddress).awardTrophy(address(this), players, matchRandomSeed, state[1], state[2], block.timestamp);
                                    }
                                }

                                uint256 winner = 0;
                                if (state[1] < state[2]) {
                                    winner = 1;
                                } else {
                                    if (state[1] == state[2]) {
                                        winner = 2;
                                    }
                                }
                                for (uint256 i=0; i < 8; i++) {
                                    uint256 data;
                                    if ((players[i] >> 16) == 0) {
                                        data = BlockheadsForBlockball(blockheadsContractAddress).tokenData(players[i]);
                                    } else {
                                        data = BlockletsForBlockball(blockletsContractAddress).tokenData(players[i]);
                                    }

                                    uint256 matchCount = (data >> (128 + 40 + 16)) & 0xff;
                                    uint256 winCount = (data >> (128 + 40 + 24)) & 0xff;
                                    uint256 winPoints = (data >> (128 + 40 + 32)) & 0xff;

                                    matchCount += 1;
                                    if ((i / 4) == winner) {
                                        winCount += 1;
                                        winPoints += 1;
                                    }

                                    uint256 noCountsMask = ~(uint256(0xffffff) << (128 + 40 + 16));
                                    data &= noCountsMask;
                                    data |= (matchCount + (winCount << 8) + (winPoints << 16)) << (128 + 40 + 16);
                                    BlockheadsForBlockball(blockheadsContractAddress).updateData(players[i], data);
                                }

                                emit Match(pointerBlueUser, pointerRedUser, state[1], state[2], players, tokenIds[0], tokenIds[1], matchRandomSeed);
                                
                                matchPlayed = true; // To prevent stack overflow

                                blueCorrect = false;

                            }
                        }
                        if (ptrBlue == ptrRed) {
                            // Processing is over
                            tournamentInProgress = false;
                            emit Tournament(tournamentId);
                        }
                    }
                    if (matchPlayed) {
                        matchesLimit -= 1;
                    } else {
                        stepsLimit -= 1;
                    }
                }
            }
        }

        if (individualId >> 128 == 0) {
            pointerRed = ptrRed;
            pointerBlue = ptrBlue;
        }
        
        if (gasRefundPriceMin > 0) {
            gasUsed = gasUsed - gasleft();

            if ((gasUsed > 500000) || (msg.sender == owner)) {
                BlockheadsForBlockball(blockheadsContractAddress).requestGasRefund(gasUsed);
            }
        }

    }

    function play(uint256 rounds, bytes32 seed, uint32[8] memory ps, bool allStates) public view returns (uint256[] memory states) {
        uint256 s = uint256(seed);
        if (allStates) {
            states = new uint256[](12 * rounds);
        } else {
            states = new uint256[](12);
        }
        uint256 x = s;
        
        uint256 excessState = MAX_UINT256 - 1; // [32 dribbleEndPosition][32 lastDribbleRound] [32 lastTackler][32 lastTackleRound]   [96 empty] [32 requestPasses]

        uint256[6] memory counts = [
            uint256(0x00000001000000010000000100000001),
            0x0000000100000001000000010000000100000000000000000000000000000000,
            0, // next round
            0, // next round
            0, // goals, team 0
            0]; // goals, team 1



        uint256[8] memory players; // To bring forward in the stack

        for (uint256 i=0; i < 8; i++) {
            if ((ps[i] >> 16) == 0) {
                players[i] = BlockheadsForBlockball(blockheadsContractAddress).tokenData(ps[i]);
            } else {
                players[i] = BlockletsForBlockball(blockletsContractAddress).tokenData(ps[i]);
            }
        }
        uint256 current = 0;

        uint256[16] memory positions = [
            uint256(0), 1, 2, 3, 7, 6, 5, 4,
            0, 0, 0, 0, 0, 0, 0, 0];

        unchecked {
            for (uint256 i=0; i < rounds; i++) {
                x = uint256(keccak256(abi.encodePacked(x, "Match")));
                uint256 currentPos = positions[current];
                
                // Tackles
                if (((excessState >> 128) & BIT_MASK_32) + 1 != i) { // Tackles cannot happen twice in a row
                    uint256 tackle = 0;
                    uint256 tacklersCount = 0;
                    uint256[4] memory tacklers;
                    uint256 maxTackle = 0;
                    uint256 maxTackler;
                    for (uint256 j = 0 + (1 - (current / 4)) * 4 ; j < 4 + (1 - (current / 4)) * 4; j++) { // Iterate opposition team
                        if (positions[j] == currentPos) {
                            uint256 t = players[j] & 0x3;
                            tackle += t;
                            tacklers[tacklersCount] = j;
                            tacklersCount += 1;
                            
                            if (t > maxTackle) { maxTackler = j; }
                        }
                    }
                    if (tackle > (players[current] >> 4) & 0x3) { // possStrength[current])
                        if (x % 2 == 0) { // 50% chance of successful tackle
                            current = maxTackler;
                            excessState = (excessState & (~(BIT_MASK_64_SMALL << 128))) | (((maxTackler << 32) | i) << 128);
                        }
                        x /= 2;
                    }
                }
                
                if (true) { // Extra scope to isolate the variables and preserve stack space
                    // Non-ball players
                    uint256 distanceBall = (DISTANCE_LISTS_MERGED >> (currentPos * 4)) & BIT_MASK_4_32_MERGED;
                    uint256 distanceGoal = (DISTANCE_LISTS_MERGED >> (7 * (1 - (current / 4))) * 4) & BIT_MASK_4_32_MERGED;
                    uint256 numAttackers = counts[current / 4];
                    uint256 numDefenders = counts[1 - (current / 4)];

                    // Reset pass requests
                    excessState = excessState & (~BIT_MASK_128_SMALL);

                    for (uint256 j=0; j<8; j++) { // Iterate players
                        bool passRequested = false;
                        if (j != current) {
                            
                            // distanceBall
                            uint256 outPoss = ((j / 4) + (current / 4)) % 2;
                            uint256 scores = distanceBall * ((players[j] >> (17 + 18 + 0 + outPoss * 8)) & 0x3);
                            
                            // distanceGoal
                            scores += distanceGoal * ((players[j] >> (17 + 18 + 2 + outPoss * 8)) & 0x3);
                            
                            // numAttackers
                            scores += numAttackers * ((players[j] >> (17 + 18 + 4 + outPoss * 8)) & 0x3);
                            
                            // numDefenders
                            scores += numDefenders * ((players[j] >> (17 + 18 + 6 + outPoss * 8)) & 0x3);
                            
                            uint256 minScore = MAX_UINT256; // [128 minScorePos][128 minScore]
                            
                            if (true) {
                                scores <<= 3;
                                scores |= BIT_MARK_3_32;
                                scores |= (NOTNEIGHBOURHOOD_MASK << positions[j]) & BIT_MASK_1R_32_UNMERGE; // Invalidating positions not in neighbourhood by setting their score's highest bit
                                if (true) {
                                    uint256 a = scores & 0xFFFFFFFF;

                                    // b = s1
                                    uint256 b = (scores >> 32) & 0xFFFFFFFF;

                                    // a = min(s0, s1)
                                    if (b < a) { a = b; }

                                    // b = s2
                                    b = (scores >> 64) & 0xFFFFFFFF;

                                    // c = s3
                                    uint256 c = (scores >> 96) & 0xFFFFFFFF;

                                    // b = min(s2, s3)
                                    if (c < b) { b = c; }

                                    // c = s4
                                    c = (scores >> 128) & 0xFFFFFFFF;

                                    // d = s5
                                    uint256 d = (scores >> 160) & 0xFFFFFFFF;

                                    // c = min(s4, s5)
                                    if (d < c) { c = d; }

                                    // d = s6
                                    d = (scores >> 192) & 0xFFFFFFFF;

                                    // e = s7
                                    uint256 e = (scores >> 224) & 0xFFFFFFFF;

                                    // d = min(s6, s7)
                                    if (e < d) { d = e; }
                                    
                                    // a = min(s0, s1, s2, s3)
                                    if (b < a) { a = b; }

                                    // c = min(s4, s5, s6, s7)
                                    if (d < c) { c = d; }
                                    
                                    // a = min(s0, s1, s2, s3, s4, s5, s6, s7)
                                    if (c < a) { a = c; }
                                    
                                    minScore = a & 0x7;
                                }
                                positions[8 + j] = minScore;
                                counts[2 + (j / 4)] += 1 << (32 * minScore);
                            }

                            // Check for Pass Request
                            if (j/ 4 == current / 4) {
                                uint256 ballPosSum = 0;
                                scores = 0;

                                // distanceGoal
                                ballPosSum += ((distanceGoal >> (32 * currentPos)) & BIT_MASK_32) * ((players[j] >> (8 + 0)) & 0x7);
                                // numAttackers
                                ballPosSum += ((numAttackers >> (32 * currentPos)) & BIT_MASK_32) * ((players[j] >> (8 + 3)) & 0x7);
                                // numDefenders
                                ballPosSum += ((numDefenders >> (32 * currentPos)) & BIT_MASK_32) * ((players[j] >> (8 + 6)) & 0x7);
                                // invPassBall
                                outPoss = 3 - ((players[current] >> 6) & 0x3); // NOTE: invPassBall, wrongly named variable to preserve stack space
                                ballPosSum += (outPoss) * ((players[j] >> (8 + 9)) & 0x7);
                                // invPossBall
                                outPoss = 3 - ((players[current] >> 4) & 0x3); // NOTE: invPossBall, wrongly named variable to preserve stack space
                                ballPosSum += (outPoss) * ((players[j] >> (8 + 12)) & 0x7);


                                // distanceGoal
                                scores += ((distanceGoal >> (32 * minScore)) & BIT_MASK_32) * ((players[j] >> (8 + 0)) & 0x7);
                                // numAttackers
                                scores += ((numAttackers >> (32 * minScore)) & BIT_MASK_32) * ((players[j] >> (8 + 3)) & 0x7);
                                // numDefenders
                                scores += ((numDefenders >> (32 * minScore)) & BIT_MASK_32) * ((players[j] >> (8 + 6)) & 0x7);
                                // invPassBall
                                outPoss = 3 - ((players[j] >> 6) & 0x3); // NOTE: invPassPlayer, wrongly named variable to preserve stack space
                                scores += (outPoss) * ((players[j] >> (8 + 9)) & 0x7);
                                // invPossBall
                                outPoss = 3 - ((players[j] >> 4) & 0x3); // NOTE: invPossPlayer, wrongly named variable to preserve stack space
                                scores += (outPoss) * ((players[j] >> (8 + 12)) & 0x7);

                                if (scores < ballPosSum) {
                                    // Requesting a pass
                                    passRequested = true; // To prevent stack overflow
                                }
                            }
                        }

                        if (passRequested) {
                            excessState = excessState | (0x1 << j);
                        }
                    }
                }
                
                // Ball player
                if ((((excessState >> 192) & BIT_MASK_32) + 1 == i) && (((excessState >> 128) & BIT_MASK_32) != i)) { // Dribble can be cancelled by a tackle
                    positions[current + 8] = excessState >> 224;
                    counts[2 + (current / 4)] += 1 << (32 * (excessState >> 224));
                    
                } else {
                    if (currentPos == 7 * (1 - (current / 4))) {
                        uint256 shotChance = 4;
                        for (uint256 j = 4 * (1 - (current / 4)); j < 4 * (1 - (current / 4)) + 4; j++) {
                            // Opposition players
                            if (positions[j] == currentPos) {
                                shotChance += (players[j] >> 2) & 0x3; // interceptStrength
                            }
                        }
                        for (uint256 j = 4 * (current / 4); j < 4 * (current / 4) + 4; j++) {
                            // Friendly players
                            if (positions[j] == currentPos) {
                                uint256 passStrength = (players[j] >> 6) & 0x3;
                                if (shotChance > passStrength) {
                                    shotChance -= passStrength;
                                } else {
                                    shotChance = 1;
                                }
                            }
                        }
                        bool shootAlways = ((players[current] >> 51) & 0x1) == 1;
                        if (shootAlways || (shotChance <= 3)) {
                            bool goal = (x % shotChance == 0);
                            x /= shotChance;
                            if (goal) {
                                // Goal
                                counts[4 + (current / 4)] += 1;

                                current = (x % 2) * 4;
                                x /= 2;
                                
                            } else {
                                // Miss
                                current = (1 - (current / 4)) * 4;
                            }
                            
                            // Repositioning players
                            positions[ 8] = 0; positions[ 9] = 1; positions[10] = 2; positions[11] = 3;
                            positions[12] = 7; positions[13] = 6; positions[14] = 5; positions[15] = 4;
                        }
                    } else {
                        // Dribble or Pass
                        uint256 minScore = MAX_UINT256; // [128 minScorePos][128 minScore]
                        for (uint256 k=0; k <= 3 + (currentPos % 3) / 2; k++) { // Iterate neighbouring positions
                            // Checking for Dribble
                            uint256 score;

                            uint256 kPos;
                            if (k == 0) {
                                kPos = currentPos;
                            } else {
                                kPos = ((NEIGHBOURHOOD_LIST >> (currentPos * 12)) >> ((k - 1) * 3)) & 0x7;
                            }

                            // distanceGoal
                            uint256 value = ((DISTANCE_MATRIX >> (kPos * 16)) >> (7 * (1 - (current / 4)) * 2)) & 0x3;
                            score = value * ((players[current] >> (8 + 0)) & 0x7); // This strategy weighting uses 3 bits

                            // numAttackers, numDefenders
                            value = 0; // [250 -][3 numAttackers][3 numDefenders]
                            value = ((counts[current / 4] >> (currentPos * 32)) & 0x3);
                            value = value | ((counts[1 - (current / 4)] >> (currentPos * 32)) & 0x3);
                            score += (value & 0x7) * ((players[current] >> (8 + 3)) & 0x7); // This strategy weighting uses 3 bits
                            score += (value >> 3) * ((players[current] >> (8 + 6)) & 0x7); // This strategy weighting uses 3 bits
                            score = score * 2 * SCORE_FACTOR;
                            
                            score += x % SCORE_RANDOM_COMPONENT;
                            x /= SCORE_RANDOM_COMPONENT;
                            
                            if (score < (minScore & BIT_MASK_128_SMALL)) {
                                minScore = (kPos << 128) | score;
                            }
                        }
                        for (uint256 j = 4 * (current / 4); j < 4 * (current / 4) + 4; j++) {
                            // Checking for Pass
                            if (j != current) { // Iterate teammates
                                if (((NEIGHBOURHOOD_MATRIX >> (current * 8)) >> j) & 0x1 == 1) {
                                    // distanceGoal
                                    uint256 value = ((DISTANCE_MATRIX >> (positions[j] * 16)) >> (7 * (1 - (current / 4)) * 2)) & 0x3;
                                    uint256 score = value * ((players[current] >> (17 + 0)) & 0x7); // This strategy weighting uses 3 bits
                                    
                                    // numAttackers, numDefenders
                                    value = 0; // [250 -][3 numAttackers][3 numDefenders]
                                    value = ((counts[current / 4] >> (currentPos * 32)) & 0x3) | ((counts[1 - (current / 4)] >> (currentPos * 32)) & 0x3);
                                    score += (value & 0x7) * ((players[current] >> (17 + 3)) & 0x7);
                                    score += (value >> 3) * ((players[current] >> (17 + 6)) & 0x7); // This strategy weighting uses 3 bits

                                    // invPoss
                                    value = 3 - ((players[j] >> 4) & 0x3);
                                    score += value * ((players[current] >> (17 + 9)) & 0x7); // This strategy weighting uses 3 bits

                                    // invPass
                                    value = 3 - ((players[j] >> 6) & 0x3);
                                    score += value * ((players[current] >> (17 + 12)) & 0x7); // This strategy weighting uses 3 bits

                                    // notRequestedPass
                                    score += (1 - ((excessState >> j) & 0x1)) * ((players[current] >> (17 + 15)) & 0x7); // This strategy weighting uses 3 bits

                                    score = score * 2 * SCORE_FACTOR;
                                    
                                    score += x % SCORE_RANDOM_COMPONENT;
                                    x /= SCORE_RANDOM_COMPONENT;
                                    
                                    if (score < (minScore & BIT_MASK_128_SMALL)) {
                                        minScore = ((8 + j) << 128) | score;
                                    }
                                }
                            }
                        }
                        if ((minScore >> 128) < 8) {
                            // Dribble

                            positions[current + 8] = positions[current];
                            counts[2 + (current / 4)] += 1 << (32 * (currentPos));

                            excessState = (excessState & (~(BIT_MASK_64_SMALL << 192))) | (((minScore >> 128) << 224) | (i << 192));

                        } else {
                            // Pass
                            // Checking for Interception
                            bool intercepted = false;
                            uint256 oppCounts = counts[1 - (current / 4)];
                            if (((oppCounts >> (32 * currentPos)) > 0) || (oppCounts >> (32 * positions[(minScore >> 128) - 8]) > 0)) { // Check if any opposition player is present to intercept (to save gas)
                                // Interception happens at pass start position or pass end position
                                uint256 maxInterceptStr = 0;
                                uint256 maxInterceptor = 0;
                                for (uint256 j = 4 * (1 - (current / 4)); j < 4 * (1 - (current / 4)) + 4; j++) {
                                    if ((positions[j] == currentPos) || (positions[j] == positions[(minScore >> 128) - 8])) {
                                        if (((players[j] >> 2) & 0x3) > maxInterceptStr) {
                                            maxInterceptStr = (players[j] >> 2) & 0x3;
                                            maxInterceptor = j;
                                        }
                                    }
                                }
                                if (maxInterceptStr >= ((players[current] >> 6) & 0x3)) { // If any interceptor's interceptStrength >= ballPlayer's passStrength
                                    // Intercepted
                                    intercepted = true;
                                    current = maxInterceptor;
                                }
                            }
                            if (!intercepted) {
                                // Successful pass
                                current = (minScore >> 128) - 8;
                            }
                        }
                    }
                }
                
                // Next state
                for (uint256 j=0; j<8; j++) {
                    positions[j] = positions[j + 8];
                }
                counts[0] = counts[2];
                counts[1] = counts[3];
                counts[2] = 0;
                counts[3] = 0;

                if (allStates || (i == rounds - 1)) {
                    uint256 offset = 0;
                    if (allStates) {
                        offset = i * 12;
                    }
                    states[offset + 0] = i;
                    states[offset + 1] = counts[4];
                    states[offset + 2] = counts[5];
                    states[offset + 3] = current;
                    states[offset + 4] = positions[0];
                    states[offset + 5] = positions[1];
                    states[offset + 6] = positions[2];
                    states[offset + 7] = positions[3];
                    states[offset + 8] = positions[4];
                    states[offset + 9] = positions[5];
                    states[offset + 10] = positions[6];
                    states[offset + 11] = positions[7];
                }
            }
        }
    }
}
