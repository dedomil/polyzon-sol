require("@nomicfoundation/hardhat-toolbox");
const { vars } = require("hardhat/config");
const PRIVATE_KEY = vars.get("PRIVATE_KEY");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.27",
  networks: {
    polygon: {
      url: `https://rpc.cardona.zkevm-rpc.com`,
      accounts: [PRIVATE_KEY],
    },
  },
};
