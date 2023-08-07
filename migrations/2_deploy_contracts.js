const GameBlockball = artifacts.require("Blockball");
const NFTBlockheads = artifacts.require("Blockheads");
const NFTBlocklets = artifacts.require("Blocklets");
const NFTBlocktrophies = artifacts.require("Blocktrophies");
const MintingBlockheads = artifacts.require("MintingBlockheads");
const UtilityFormatting = artifacts.require("UtilityFormatting");
const UtilityGLTF = artifacts.require("UtilityGLTF");

module.exports = function(deployer) {
    deployer.deploy(GameBlockball, NFTBlockheads.address, {gas: 12000000});
    deployer.deploy(NFTBlocklets, NFTBlockheads.address, {gas: 12000000});
    deployer.deploy(NFTBlocktrophies, NFTBlockheads.address, {gas: 12000000});
    deployer.deploy(MintingBlockheads, NFTBlockheads.address, {gas: 12000000});
    deployer.deploy(UtilityFormatting, NFTBlockheads.address, {gas: 12000000});
    deployer.deploy(UtilityGLTF, {gas: 12000000});
};
