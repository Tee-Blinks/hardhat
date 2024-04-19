const { ethers } = require("hardhat");

async function toks() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const AjoToken = await ethers.getContractFactory("AjoToken");
  const ajoToken = await AjoToken.deploy(1000);
  await ajoToken.deployed();


  console.log("AjoToken deployed to:", ajoToken.address);

}

toks()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

// 0x7C2A1e2A62E2AA0311bD39587c29223C2eA20F9F
// 0x35231E4080fb06586457e2D2c6B63072D9CDF707

