const NFTBlockheads = artifacts.require("Blockheads");
const NFTBlocklets = artifacts.require("Blocklets");
const NFTBlocktrophies = artifacts.require("Blocktrophies");
const MintingBlockheads = artifacts.require("MintingBlockheads");
const UtilityFormatting = artifacts.require("UtilityFormatting");
const GameBlockball = artifacts.require("Blockball");

function logEvents(tx) {
    for (const log of tx.logs) {
      var argsStr = "";
      var args = log.args;
      var argI = 0;
      var formatting = "";
      while (argI.toString() in args) {
        if (argI > 0) {
          argsStr += ", ";
        }
        var arg = args[argI.toString()];
        if ((typeof arg == "string") && (arg.length == 42 && arg.slice(0, 2) == "0x")) {
            // Address
            argsStr += arg;
        } else {
            if (formatting == "0b" && ("words" in arg)) {
            argsStr += "0b" + arg.toString(2);
            } else {
            if (formatting.slice(0, 2) == "0b" && ("words" in arg)) {
                var tabLength = parseInt(formatting.split("'")[1].split("/")[0]);
                var fullLength = parseInt(formatting.split("'")[1].split("/")[1]);
                argsStr += "\n  0b ";
                var binary = arg.toString(2);
                binary = binary.padStart(fullLength, "0");
                var i = 0;
                
                while (i < fullLength) {
                argsStr += binary.slice(i, i + tabLength) + " ";
                i += tabLength;
                }
                argsStr += "\n     ";
                
                i = 0;
                while (i < fullLength) {
                argsStr += parseInt(binary.slice(i, i + tabLength), 2).toString().padStart(tabLength, " ") + " ";
                i += tabLength;
                }
                argsStr += "\n";
            } else {
                if (formatting == "0x" && ("words" in arg)) {
                argsStr += "0x" + arg.toString(16);
                } else {
                argsStr += arg.toString();
                if ((typeof arg == "string") && arg.slice(0,1) == "0") {
                    formatting = arg.slice(0,2);
                    if (arg.indexOf('/') > -1) {
                    formatting += "'" + arg.split("'")[1];
                    }
                }
                }
            }
            }
        }
        argI++;
      }
      console.log(log.event + "(" + argsStr + ")");
    }
  }

contract('Blockheads', (accounts) => {
  it('should do some auctions', async () => {

    const gameBlockball = await GameBlockball.deployed();
    const nftBlockheads = await NFTBlockheads.deployed();
    const nftBlocklets = await NFTBlocklets.deployed();
    const nftBlocktrophies = await NFTBlocktrophies.deployed();
    const mintingBlockheads = await MintingBlockheads.deployed();
    const utilityFormatting = await UtilityFormatting.deployed();

    const zeroAddress = "0x0000000000000000000000000000000000000000";
    await nftBlockheads.setContractAddresses(gameBlockball.address, mintingBlockheads.address, nftBlocklets.address, nftBlocktrophies.address, utilityFormatting.address, {gas: 5000000});

    
    console.log(" - Contract deployed")

    await nftBlockheads.presetTokens([2, 3], {gas: 5000000});
    console.log(" - Tokens set")

    const result = await nftBlockheads.finalize({gas: 5000000});
    console.log(" - Finalized")
    logEvents(result);

    var firstId = (await nftBlockheads.currentAuctionsFirstId.call()).toNumber();
    console.log(firstId);

    function timeout(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    batchSize = 6;

    var j = 0;
    for (let i = 0; i < 60; i++) {
        console.log(" - Waiting..");
        await timeout(1000);
        console.log(" - Waited");
        firstId = (await nftBlockheads.currentAuctionsFirstId.call()).toNumber();

        await nftBlockheads.empty({gas: 5000000});
        const price = await nftBlockheads.getAuctionPrice.call();
        console.log(price.toString());

        if (price.toString() != "0") {
            console.log(" - Minting");
            const tx = await nftBlockheads.mint(firstId + (j % batchSize), {value: price, from: accounts[0], gas: 5000000});
            logEvents(tx);
            j += 1;
        }
    }

  });
});
