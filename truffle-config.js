module.exports = {
  networks: {
   development: {
     host: "127.0.0.1",
     port: 7545,
     network_id: "*",
     gas: 1200000000,
     before_timeout: 3600000,
     test_timeout: 3600000,
     timeout: 3600000
   },
   test: {
     host: "127.0.0.1",
     port: 7545,
     network_id: "*",
     gas: 1200000000,
     before_timeout: 3600000,
     test_timeout: 3600000,
     timeout: 3600000
   },
   develop: {
    port: 8545,
    network_id: 20,
    accounts: 5,
    defaultEtherBalance: 500,
    blockTime: 3,
    gas: 1200000000
   }
  },

  compilers: {
    solc: {
      version: "0.8.10",
      settings: {
        optimizer: {
          enabled: true,
          runs: 200,
        },
      }
    }
  },

  mocha: {
    enableTimeouts: false,
    before_timeout: 3600000,
    timeout: 3600000
  }
};