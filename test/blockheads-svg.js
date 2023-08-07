const NFTBlockheads = artifacts.require("Blockheads");
const NFTBlocklets = artifacts.require("Blocklets");
const NFTBlocktrophies = artifacts.require("Blocktrophies");
const MintingBlockheads = artifacts.require("MintingBlockheads");
const UtilityFormatting = artifacts.require("UtilityFormatting");
const GameBlockball = artifacts.require("Blockball");
const UtilityGLTF = artifacts.require("UtilityGLTF");
const fsPromises = require('fs').promises;
const fs = require('fs');
const execSync = require('child_process').execSync;
const randomBytes = require('crypto').randomBytes;
const sharp = require("sharp");

String.prototype.replaceAt = function(index, replacement) {
    return this.slice(0, index) + replacement + this.slice(index + replacement.length);
}

contract('Blockheads', (accounts) => {
  it('should return tokenURI', async () => {
    
    const nftBlockheads = await NFTBlockheads.deployed();
    const gameBlockball = await GameBlockball.deployed();
    const nftBlocklets = await NFTBlocklets.deployed();
    const nftBlocktrophies = await NFTBlocktrophies.deployed();
    const mintingBlockheads = await MintingBlockheads.deployed();
    const utilityFormatting = await UtilityFormatting.deployed();
    const utilityGLTF = await UtilityGLTF.deployed();

    const zeroAddress = "0x0000000000000000000000000000000000000000";

    await nftBlockheads.setContractAddresses(zeroAddress, mintingBlockheads.address, nftBlocklets.address, nftBlocktrophies.address, utilityFormatting.address, {gas: 5000000});
    await utilityFormatting.setGLTFContractAddress(utilityGLTF.address, {gas: 5000000});

    var bytecode = nftBlockheads.constructor._json.bytecode;
    var deployed = nftBlockheads.constructor._json.deployedBytecode;
    var sizeOfB  = bytecode.length / 2;
    var sizeOfD  = deployed.length / 2;
    console.log("size of deployed in bytes = ", sizeOfD);

    console.log("Blockball size     = ", gameBlockball.constructor._json.deployedBytecode.length / 2);
    console.log("Blockheads size    = ", nftBlockheads.constructor._json.deployedBytecode.length / 2);
    console.log("Blocklets size     = ", nftBlocklets.constructor._json.deployedBytecode.length / 2);
    console.log("Blocktrophies size = ", nftBlocktrophies.constructor._json.deployedBytecode.length / 2);
    console.log("Minting size       = ", mintingBlockheads.constructor._json.deployedBytecode.length / 2);
    console.log("Utility size       = ", utilityFormatting.constructor._json.deployedBytecode.length / 2);

    console.log(" - Contract deployed")

    var preset = [];

    const blocksCount = 8;
    const presetLength = preset.length;

    for (let i = 0; i < blocksCount - presetLength; i++) {
        const value = randomBytes(32);
        const str = value.toString('hex');
        preset.push("0x" + str.replaceAt(2 * 8, "000000"));
    }

    console.log(preset);

    const traitMods = [8, 8, 3, 3, 16, 16]

    var i,j, temporary, chunk = 32;
    for (i = 0,j = preset.length; i < j; i += chunk) {
        presetSlice = preset.slice(i, i + chunk);
        await nftBlockheads.presetTokens(presetSlice, {gas: 5000000});
    }

    console.log(" - Tokens set")
    
    for (let i = 0; i < preset.length; i++) {
        console.log(" - Generating: " + preset[i].toString());
        var uriFull = await nftBlockheads.tokenURI.call(i);
        let buff = Buffer.from(uriFull.slice(29), 'base64');
        uriFull = buff.toString('ascii');
        const uri = uriFull;
        const stringLength = uri.length;
        const newURI = uri.substring(0, stringLength);
        const tokenURI = JSON.parse(newURI);
        console.log(tokenURI);

        console.log("===============================================================================");

        let buff3d = Buffer.from(tokenURI.animation_url.slice(26), 'base64');
        let text3d = buff3d.toString('ascii');
        const currentGLTF = text3d;
        const traitsHash3d = preset[i].slice(24,34).toUpperCase();

        console.log(currentGLTF);
        console.log("------------------------------");

        await fsPromises.writeFile("svg\\Blockheads-GLTF\\" + traitsHash3d + ".gltf", currentGLTF, { flag: 'w+' }, err => { console.log("ERROR") });

        console.log("===============================================================================");

        let buff2 = Buffer.from(tokenURI.image.slice(26), 'base64');
        let text = buff2.toString('ascii');
        const currentSVG = text;
        
        const traitsHash = preset[i].slice(24,34).toUpperCase();
        console.log(traitsHash);

        await fsPromises.writeFile("svg\\Blockheads-SVG\\" + traitsHash + ".svg", currentSVG, { flag: 'w+' }, err => { console.log("ERROR") });
        
        sharp("svg\\Blockheads-SVG\\" + traitsHash + ".svg")
        .png()
        .toFile("svg\\Blockheads-PNG\\" + traitsHash + ".png")
        .then(function(info) {
            console.log(info)
        })
        .catch(function(err) {
            console.log(err)
        })
        
        const currentText = traitsHash + "," + tokenURI['data'] + "," + tokenURI.attributes[0]['value'] + "," + tokenURI.attributes[1]['value'] + "," + tokenURI.attributes[2]['value'] + "," + tokenURI.attributes[3]['value'] + "," + tokenURI.attributes[4]['value'] + "," + tokenURI.attributes[5]['value'] + "\n";
        await fsPromises.writeFile("svg\\Blockheads-TXT\\" + traitsHash + ".txt", currentText, { flag: 'w+' }, err => { console.log("ERROR") });

        await fsPromises.appendFile("svg\\Blockheads.csv", currentText, err => { console.log("ERROR") });
    }

    console.log(preset);

  }).timeout(5*3600000);
});
