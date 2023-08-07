const NFTBlockheads = artifacts.require("Blockheads");

module.exports = function(deployer) {
    deployer.deploy(NFTBlockheads, {gas: 12000000});
};
