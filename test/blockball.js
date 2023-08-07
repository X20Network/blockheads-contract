const assert = require('assert');
const { join } = require('path');

const NFTBlockheads = artifacts.require("Blockheads");
const NFTBlocklets = artifacts.require("Blocklets");
const NFTBlocktrophies = artifacts.require("Blocktrophies");
const MintingBlockheads = artifacts.require("MintingBlockheads");
const UtilityFormatting = artifacts.require("UtilityFormatting");
const GameBlockball = artifacts.require("Blockball");
const randomBytes = require('crypto').randomBytes;
const fsPromises = require('fs').promises;
const execSync = require('child_process').execSync;
const sharp = require("sharp");

function drawCell(state, stateExcess, c, t) {
  let colorRed = '\x1b[31m';
  let colorBlue = '\x1b[94m';
  let colorBlueDark = '\x1b[34m';
  let colorBG = '\x1b[100m';
  let colorBGYellow = '\x1b[43m';
  let colorStop = '\x1b[0m';
  let colorYellow = '\x1b[33m';

  var str = "";
  for (let pi = 4 * t + 0; pi < 4 * t + 4; pi++) {
    if (state[4 + pi] == c) {
      if (t == 0) {
        if (state[3] == pi) {
          str += colorBlueDark;
          str += colorBG;
        } else {
          str += colorBlue;
        }
      } else {
        str += colorRed;
        if (state[3] == pi) {
          str += colorBG;
        }
      }
      str += pi.toString();
      str += colorStop;
    } else {
      if (((stateExcess[1] == state[0]) && (state[3] == pi)) && (stateExcess[0] == c)) { // Started dribbling this round and the player has the ball and the position is the next one
        str += colorYellow;
        str += "×";
        str += colorStop;
      } else {
        str += " ";
      }
    }
  }
  return str;
}

function logEvents(tx) {
  let colorRed = '\x1b[31m';
  let colorBlue = '\x1b[94m';
  let colorBG = '\x1b[100m';
  let colorStop = '\x1b[0m';

  var stateExcess = [];
  var lastBallAction = "";

  for (const log of tx.logs) {
    var argsStr = "";
    var args = log.args;
    var argI = 0;
    var formatting = "";
    if (log.event == "StateExcess") {
      stateExcess = [];
    }
    var state = [];
    while (argI.toString() in args) {
      if (argI > 0) {
        argsStr += ", ";
      }
      var arg = args[argI.toString()];
      if (log.event == "State") {
        state.push(arg);
      }
      if (log.event == "StateExcess") {
        stateExcess.push(arg.toNumber());
      }
      if (log.event == "Ball") {
        lastBallAction = arg;
      }
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
      argI++;
    }
    console.log(log.event + "(" + argsStr + ")");
    if (log.event == "State") {
      console.log('╔════╤════╤════╗');
      console.log('║     ' + drawCell(state, stateExcess, 7, 1) + '     ║');
      console.log('║     ' + drawCell(state, stateExcess, 7, 0) + '     ║');
      console.log('╠════╦════╦════╣');
      console.log('║' + drawCell(state, stateExcess, 4, 1) + '║'  + drawCell(state, stateExcess, 5, 1) + '║'  + drawCell(state, stateExcess, 6, 1) + '║');
      console.log('║' + drawCell(state, stateExcess, 4, 0) + '║'  + drawCell(state, stateExcess, 5, 0) + '║'  + drawCell(state, stateExcess, 6, 0) + '║' + colorRed + "▐".repeat(state[2]) + colorStop);
      console.log('╠════╬════╬════╣');
      console.log('║' + drawCell(state, stateExcess, 1, 1) + '║'  + drawCell(state, stateExcess, 2, 1) + '║'  + drawCell(state, stateExcess, 3, 1) + '║' + colorBlue + "▐".repeat(state[1]) + colorStop);
      console.log('║' + drawCell(state, stateExcess, 1, 0) + '║'  + drawCell(state, stateExcess, 2, 0) + '║'  + drawCell(state, stateExcess, 3, 0) + '║');
      console.log('╠════╩════╩════╣ ' + lastBallAction);
      console.log('║     ' + drawCell(state, stateExcess, 0, 1) + '     ║');
      console.log('║     ' + drawCell(state, stateExcess, 0, 0) + '     ║');
      console.log('╚════╧════╧════╝');
    }
  }
}

contract('Blockball', (accounts) => {
  it('should return game result', async () => {

    const gameBlockball = await GameBlockball.deployed();
    const nftBlockheads = await NFTBlockheads.deployed();
    const nftBlocklets = await NFTBlocklets.deployed();
    const nftBlocktrophies = await NFTBlocktrophies.deployed();
    const mintingBlockheads = await MintingBlockheads.deployed();
    const utilityFormatting = await UtilityFormatting.deployed();

    const zeroAddress = "0x0000000000000000000000000000000000000000";
    await nftBlockheads.setContractAddresses(gameBlockball.address, mintingBlockheads.address, nftBlocklets.address, nftBlocktrophies.address, utilityFormatting.address, {gas: 5000000});

    console.log(" - Contract references set");

    var preset = [];
    const blocksCount = 16;
    for (let i = 0; i < blocksCount; i++) {
        const value = randomBytes(32);
        const str = value.toString('hex');
        preset.push("0x" + str);
    }
    console.log(preset);


    await nftBlockheads.presetTokens(preset, {gas: 5000000});
    console.log(" - Tokens preset")

    const teams = [
        0, 1, 2, 3, 0, 1,
        4, 5, 6, 7, 0, 1,
        8, 9, 10, 11, 0, 1,
        12, 13, 14, 15, 0, 1
    ];
    const tournamentsCount = 8;

    const value = randomBytes(32);
    const str = value.toString('hex');
    salt = "0x" + str;
    console.log(salt);

    commitmentHash = web3.utils.soliditySha3({type: 'uint256', value: teams}, {type: 'bytes32', value: salt});
    
    console.log(commitmentHash);
    let commitTeams = await gameBlockball.commitTeams(0, commitmentHash, {gas: 5000000});
    console.log(" - Team committed");
    logEvents(commitTeams);

    let revealTeams = await gameBlockball.revealTeams(accounts[0], teams, salt, {gas: 5000000});
    console.log(" - Team revealed");
    logEvents(revealTeams);
    
    function timeout(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    const matchesCount = ~~(teams.length / 12);
    for (let i = 0; i < tournamentsCount; i++) {
        let processTournament = await gameBlockball.processTournament(4096, 4096, 4096, 0, 0, {gas: 12000000});

        await timeout(10000);

        console.log(" - Tournament processed: #" + i.toString());
        logEvents(processTournament);

        for (let j = 0; j < matchesCount; j++) {
            console.log(" - Generating SVG: #" + j.toString());
            const uri = await nftBlocktrophies.tokenURIhidden.call(i * matchesCount + j);
            console.log(uri);


            const stringLength = uri.indexOf(String.fromCharCode(0));
            console.log(stringLength);
            const newURI = uri.substring(0, stringLength);
            const tokenURI = JSON.parse(newURI);
            
            console.log(tokenURI.attributes);

            const currentSVG = tokenURI.image.slice(25);


            var traitsHash = "";

            traitsHash = randomBytes(4).toString('hex').toUpperCase();
            console.log(traitsHash);


            await fsPromises.writeFile("svg\\Blocktrophies-SVG\\" + traitsHash + ".svg", currentSVG, { flag: 'w+' }, err => { console.log("ERROR") });
            sharp("svg\\Blocktrophies-SVG\\" + traitsHash + ".svg")
            .png()
            .toFile("svg\\Blocktrophies-PNG\\" + traitsHash + ".png")
            .then(function(info) {
                console.log(info)
            })
            .catch(function(err) {
                console.log(err)
            });
        }
    }

  });
});
