const hre = require("hardhat");

async function main() {
  const CannabioToken = await hre.ethers.getContractFactory("ERC20");
  const cannabioToken = await CannabioToken.deploy(1500000);

  await cannabioToken.deployed();

  console.log("Cannabio Token deployed: ", cannabioToken.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
