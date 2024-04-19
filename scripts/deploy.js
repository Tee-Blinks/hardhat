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


  //AutoSaver 0xC220eeF6Bf7f5Dd9118Fc9f4c264BA4397149d1C

 