const { ethers} = require("hardhat");

async function main() {
  // const provider = waffle.provider;
  const [user1,user2,user3,user4,user5] = await ethers.getSigners();
  
  // const Test1 = await ethers.getContractFactory("MooseSociety");
  // const test1 = await Test1.deploy();
  
  // await test1.deployed();
  // console.log(`Test1 contracts deployed to ${test1.address}`);
  // 0xC0485b2005a6840180937A7cc6b89BBed2281b94

  // const Test2 = await ethers.getContractFactory("AlphaIsand");
  // const test2 = await Test2.deploy();
  
  // await test2.deployed();
  // console.log(`Test2 contracts deployed to ${test2.address}`);
  // 0x91133E3BB20a9183eED2c9cf8DaD28D2d268BACb

  // const Test3 = await ethers.getContractFactory("GROUCHYTIGERS");
  // const test3 = await Test3.deploy();
  
  // await test3.deployed();
  // console.log(`Test3 contracts deployed to ${test3.address}`);
  // 0x6bf946A39701f8A2eb5F33e31F4D092eb8ed90D9

  const Astronauts = await ethers.getContractFactory("Astronauts");
  const astronauts = await Astronauts.deploy();
  await astronauts.deployed();
  console.log(`AstroNAUTS contracts deployed to ${astronauts.address}`);
// 0x6A73666C85f2F955E2992E38E966Bf0f8775319d

  // await astronauts.addValidator(user2.address)  
  // console.log(await astronauts.contractBalance())
  // await user1.sendTransaction({value:100,to:astronauts.address});
  // console.log(await astronauts.contractBalance())

  // console.log(await ethers.provider.getBalance(user3.address))
  // await astronauts.connect(user2).withdrawEthers(100);
  // console.log(await ethers.provider.getBalance(user3.address))
  // console.log(await astronauts.contractBalance())

  // await astronauts.connect(user3).removeValidator(user2.address)
  // await astronauts.connect(user2).addValidator(user3.address)  
  // console.log(await astronauts.validator(user2.address));
  // console.log(await astronauts.validator(user3.address));


  // console.log(await astronauts.balanceOf(user2.address))
  // console.log(await astronauts.contractBalance())
  // await astronauts.connect(user2).MintInvestorNFTs(user2.address,3,{value:15000});

  // console.log(await astronauts.balanceOf(user2.address))
  // console.log(await astronauts.contractBalance())

  // console.log(await astronauts.totalSupply());
  
  // console.log(await astronauts.balanceOf(user4.address));
  // await astronauts.connect(user4).claimFreeInvestorNFTs()
  // await astronauts.connect(user2).claimFreeInvestorNFTs()
  // await astronauts.connect(user3).claimFreeInvestorNFTs()
  // console.log(await astronauts.balanceOf(user4.address));
  
  // await astronauts.pauseUnpauseDiscountMint(true);
  // console.log(await astronauts.totalSupply());
  // await astronauts.connect(user5).MintDiscountedInvestorNFTs(user2.address,19,{value:11110});  
  // console.log(await astronauts.totalSupply());

  // await astronauts.removeNFTProject(user2.address);

  // for(let i=0;i<10;i++){
  //   try {
  //     console.log(await astronauts.NFTProjects(i));
  //   } catch (error) {
  //     console.log(error.message)
  //     break;
  //   }
  // }
  // console.log(await astronauts.totalSupply());
  // await astronauts.connect(user3).MintInvestorNFTs(user3.address,1,{value:1000});
  // await astronauts.connect(user2).MintInvestorNFTs(user2.address,1,{value:1000});
  // console.log(await astronauts.totalSupply());
  // console.log(await astronauts.balanceOf(user3.address))
  // console.log(await astronauts.ownerOf(0))
  // await astronauts.connect(user3).stakeInvestorNFT(0);
  
  // console.log(await astronauts.ownerOf(0))
  // console.log(await astronauts.StakedNFTbyId(0))
  
  // await astronauts.connect(user3).unstakeInvestorNFT(0);

  // console.log(await astronauts.ownerOf(0))
  // console.log(await astronauts.StakedNFTbyId(0))



}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

// npx hardhat verify --contract contracts/Crypto3d.test.sol:Crypto3dTest --network rinkeby 0xa0957418DA97756532Ae2aA553B68B316bbCDf9F 
