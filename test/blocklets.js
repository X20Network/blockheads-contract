const NFTBlockheads = artifacts.require("Blockheads");
const NFTBlocklets = artifacts.require("Blocklets");
const NFTBlocktrophies = artifacts.require("Blocktrophies");
const MintingBlockheads = artifacts.require("MintingBlockheads");
const UtilityFormatting = artifacts.require("UtilityFormatting");
const GameBlockball = artifacts.require("Blockball");
const fsPromises = require('fs').promises;
const execSync = require('child_process').execSync;
const randomBytes = require('crypto').randomBytes;
const sharp = require("sharp");

contract('Blocklets', (accounts) => {
  it('should return tokenURI', async () => {

    const nftBlockheads = await NFTBlockheads.deployed();
    const gameBlockball = await GameBlockball.deployed();
    const nftBlocklets = await NFTBlocklets.deployed();
    const nftBlocktrophies = await NFTBlocktrophies.deployed();
    const mintingBlockheads = await MintingBlockheads.deployed();
    const utilityFormatting = await UtilityFormatting.deployed();

    const zeroAddress = "0x0000000000000000000000000000000000000000";
    await nftBlockheads.setContractAddresses(gameBlockball.address, mintingBlockheads.address, nftBlocklets.address, nftBlocktrophies.address, utilityFormatting.address, {gas: 5000000});
    console.log(" - Contract deployed: Blocklets")

    var preset = [];
    const blocksCount = 4;
    for (let i = 0; i < blocksCount; i++) {
        const value = randomBytes(32);
        const str = value.toString('hex');

        preset.push("0x" + str);
    }
    console.log(preset);

    var i,j, temporary, chunk = 32;
    for (i = 0,j = preset.length; i < j; i += chunk) {
        presetSlice = preset.slice(i, i + chunk);
        await nftBlocklets.presetTokens(presetSlice, {gas: 5000000});
    }

    console.log(" - Tokens set")

    for (let i = 0; i < blocksCount; i++) {
        const uriFull = await nftBlocklets.tokenURIhidden.call(i);
        
        let buff = Buffer.from(uriFull.slice(29), 'base64');
        let newURI = buff.toString('ascii');
        const tokenURI = JSON.parse(newURI);
        
        console.log(tokenURI);

        let buff2 = Buffer.from(tokenURI.image.slice(26), 'base64');
        let currentSVG = buff2.toString('ascii');

        var traitsHash = "";
        let traitNumber = parseInt("0x".concat(preset[i].slice(30, 32))) % 16
        traitsHash = traitsHash.concat(traitNumber.toString(16).padStart(2, "0").toUpperCase());
        console.log(traitsHash);

        await fsPromises.writeFile("svg\\Blocklets-SVG\\" + traitsHash + ".svg", currentSVG, { flag: 'w+' }, err => { console.log("ERROR") });
        sharp("svg\\Blocklets-SVG\\" + traitsHash + ".svg")
        .png()
        .toFile("svg\\Blocklets-PNG\\" + traitsHash + ".png")
        .then(function(info) {
            console.log(info)
        })
        .catch(function(err) {
            console.log(err)
        });
    }
    
  });

});
