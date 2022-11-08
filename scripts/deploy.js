// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
// const hre = require("hardhat");
const { ethers} = require("hardhat");

async function main() {
  // const provider = waffle.provider;
  const [user1,user2,user3,user4] = await ethers.getSigners();
  const OnboardReignLabs = await ethers.getContractFactory("OnboardReignLabs");
  const onboardReignLabs = await OnboardReignLabs.deploy();

  await onboardReignLabs.deployed();

  console.log(`OnboardReignLabs contracts deployed to ${onboardReignLabs.address}`);

  
  await onboardReignLabs.buyTokenPass(user1.address,0,{value:"140000000000000000"});
  await onboardReignLabs.buyTokenPass(user1.address,0,{value:"140000000000000000"});
  await onboardReignLabs.connect(user1).safeTransferFrom(user1.address,user2.address,0,1,"0x00");
  console.log(await onboardReignLabs.balanceOf(user1.address,0));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
