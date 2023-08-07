const NFTBlockheads = artifacts.require("Blockheads");

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

    const nftBlockheads = await NFTBlockheads.deployed();
    console.log(" - Contract deployed")

    await nftBlockheads.presetTokens([2, 3], {gas: 5000000});
    console.log(" - Tokens set")

    const data = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
    const result = await nftBlockheads.finalize(data, {gas: 5000000});
    console.log(" - Finalized")
    logEvents(result);

    const merkleRoot = await nftBlockheads.tokenDataMerkleRoot.call();
    console.log(merkleRoot);
    console.log(" - Tree built")

    const nodes = [
        "0x0000000000000000000000000000000000000000000000000000000000000008",
        "0xc47c2f4ab42fe2617dd76ca1eb9781d09fced5e5671df71824e2f8a8f694e024",
        "0x0000000000000000000000000000000000000000000000000000000000000000",
        "0x29828f51242d896ead379c3ae17da8f37b020e3189190c95d2e462bf4493f533",];
    
    const result2 = await nftBlockheads.verifyTokenData(9, 9, nodes, {gas: 5000000});
    logEvents(result2);

  });
});
