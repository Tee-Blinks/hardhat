const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const AutoSaver = await ethers.getContractFactory("AutoSaver");
  const autoSaver = await AutoSaver.deploy('0x35231E4080fb06586457e2D2c6B63072D9CDF707');
  await autoSaver.deployed();

  console.log("AutoSaver deployed to:", autoSaver.address);


}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

  //0xabb1d7d4c0037b3d65b8da93e462584234109b3e
  // Autosaver: 0x3b09A22d7A724347C9723594C8eA7EcaDf00feFC
  // Ajo: 0x35231E4080fb06586457e2D2c6B63072D9CDF707