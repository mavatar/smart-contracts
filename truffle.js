var HDWalletProvider = require("truffle-hdwallet-provider");

const infura_apikey = process.env.INFURA_APIKEY
const mnemonic = process.env.METAMASK_MNEMONIC

module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*" // Match any network id
    },
    ropsten: {
      provider: new HDWalletProvider(mnemonic, "https://ropsten.infura.io/"+infura_apikey),
      network_id: 3,
      gas:  4700036,
    },
    rinkeby: {
      host: "localhost",
      port: 8555,
      network_id: 3,
      // provider: new HDWalletProvider(mnemonic, "https://rinkeby.infura.io/"+infura_apikey),
      network_id: 4,
      gas: 4612388,
    }
  }
};
