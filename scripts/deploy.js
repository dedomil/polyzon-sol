const hardhat = require("hardhat");

async function main() {
  const ecf = await hardhat.ethers.getContractFactory("Esurf");
  const cf = await ecf.deploy()

  console.log(await cf.getAddress());
}

main();