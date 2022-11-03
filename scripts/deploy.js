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
  // 0x96B7c3B7E5D80252FE76122824f525E7AA906A17
  // await onboardReignLabs.connect(user3).buyBasic(user3.address,{value:'140000000000000000'});
  // console.log(await onboardReignLabs.balanceOf(user2.address,0));
  // console.log(await onboardReignLabs.balanceOf(user2.address,1));
  // await onboardReignLabs.connect(user2).buyElite(user2.address,1,{value:'740000000000000000'});
  // console.log(await onboardReignLabs.balanceOf(user2.address,0));
  // console.log(await onboardReignLabs.balanceOf(user2.address,1));
  // await onboardReignLabs.connect(user2).buyPro(user2.address,1,{value:'6660000000000000000'});
 
  // console.log(await onboardReignLabs.balanceOf(user2.address,2));
  // console.log(await onboardReignLabs.balanceOf(user2.address,1));

  // console.log(await onboardReignLabs.EliteFee());
  // await onboardReignLabs.updatePassPrice(1,"111111111111111111");
  // console.log(await onboardReignLabs.EliteFee());
  // console.log(await onboardReignLabs.contractBalance());
  // console.log(await ethers.provider.getBalance(user1.address));
  // let a =await ethers.provider.getBalance(user1.address);
  // let b =await ethers.provider.getBalance(user2.address);
  // console.log(await ethers.provider.getBalance(user2.address));
  
  
  // await onboardReignLabs.withDrawEthers();
  // console.log(await onboardReignLabs.contractBalance());
  // console.log((await ethers.provider.getBalance(user1.address))-a);
  // console.log((await ethers.provider.getBalance(user2.address))-b);
  // console.log(await onboardReignLabs.getRevenueSplitAddresses());
  // console.log(await onboardReignLabs.RevenueSplit(user1.address))
  // console.log(await onboardReignLabs.RevenueSplit(user2.address))
  // await onboardReignLabs.updateRevenueSplits(user2.address,400)
  // await onboardReignLabs.updateRevenueSplits(user4.address,100)
  // console.log(await onboardReignLabs.RevenueSplit(user1.address))
  // console.log(await onboardReignLabs.RevenueSplit(user2.address))
  // console.log(await onboardReignLabs.RevenueSplit(user4.address))
  // console.log(await onboardReignLabs.getRevenueSplitAddresses());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
