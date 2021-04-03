require("@nomiclabs/hardhat-waffle");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async () => {
  const accounts = await ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */

/*
module.exports = {
  solidity: "0.7.3",
};
*/

module.exports = {
  defaultNetwork: "kovan",
  networks: {
    hardhat: {
    },
    /*kovan: {
      url: 'YOUR INFURA',
      accounts: ['YOUR PRIVATE KEY']
    },*/
  },
  solidity: {
    compilers: [
      {
        version: "0.6.0"
      },
      {
        version: "0.7.3",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      }
    ]
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout: 20000
  }
}

