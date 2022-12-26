const { ethers} = require("hardhat");

async function main() {
  // const provider = waffle.provider;
  const [user1,user2,user3,user4,user5,user6,user7,user8,user9,user10] = await ethers.getSigners();
  
  const Test1 = await ethers.getContractFactory("MooseSociety");
  const test1 = await Test1.deploy();
  
  await test1.deployed();
  console.log(`Test1 contracts deployed to ${test1.address}`);
  // 0xC0485b2005a6840180937A7cc6b89BBed2281b94

  const Test2 = await ethers.getContractFactory("AlphaIsand");
  const test2 = await Test2.deploy();
  
  await test2.deployed();
  console.log(`Test2 contracts deployed to ${test2.address}`);
  // 0x91133E3BB20a9183eED2c9cf8DaD28D2d268BACb

  // const Test3 = await ethers.getContractFactory("GROUCHYTIGERS");
  // const test3 = await Test3.deploy();
  
  // await test3.deployed();
  // console.log(`Test3 contracts deployed to ${test3.address}`);
  // 0x6bf946A39701f8A2eb5F33e31F4D092eb8ed90D9

  const Astronauts = await ethers.getContractFactory("Astronauts");
  const astronauts = await Astronauts.deploy(test1.address,test2.address);
  await astronauts.deployed();      
  console.log(`AstroNAUTS contracts deployed to ${astronauts.address}`);
  // 0xefd01290f32a48758820DA65b0dFAd7Bc281bbEC

  await test1.safeMint(user2.address,1);
  await test1.safeMint(user4.address,2);
  await test1.safeMint(user5.address,3);
  await test1.safeMint(user6.address,4);
  await test1.safeMint(user7.address,5);

  await test2.safeMint(user3.address,1);
  await test2.safeMint(user3.address,3);
  await test2.safeMint(user4.address,2);
  await test2.safeMint(user5.address,4);
  await test2.safeMint(user6.address,5);
  await test2.safeMint(user7.address,6);


  // Add burnable function.

  // await astronauts.updtateNFTPice(false,127);

  // await astronauts.addNFTProject(test2.address)
  // await astronauts.removeNFTProject(test1.address)
  // await astronauts.removeNFTProject(test2.address)
  // console.log(await astronauts.NFTProjects(0))
  // console.log(await astronauts.NFTProjects(1))

  // console.log(await astronauts.NFTprice())  
  // console.log(await astronauts.DiscountedNFTprice())
  // await astronauts.pauseUnpauseDiscountMint(true);
  // await astronauts.pauseUnpauseDiscountMint(false);
  // await astronauts.connect(user6).MintDiscountedInvestorNFTs(user6.address,1,{value:119});
  // await astronauts.connect(user6).MintDiscountedInvestorNFTs(user6.address,1,{value:119});

  // console.log(await astronauts.MultiSigWallet());
  // console.log(user10.address);
  

  // let x= await ethers.provider.getBalance(user10.address);
  // console.log(x);

  // console.log(await astronauts.totalSupply());
  // console.log(await astronauts.balanceOf(user6.address))
  // await astronauts.connect(user6).burn(1)
  // console.log(await astronauts.totalSupply());
  // console.log(await astronauts.balanceOf(user6.address))


  // await astronauts.connect(user6).stakeInvestorNFT([1,1])


  








































  // console.log(await astronauts.contractBalance())
  
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
  // console.log(await ethers.provider.getBalance(user4.address))
  
  // await astronauts.connect(user2).MintInvestorNFTs(user2.address,6,{value:15000});
  // await astronauts.connect(user3).MintInvestorNFTs(user3.address,2,{value:15000});
  // await astronauts.connect(user2).MintInvestorNFTs(user2.address,2,{value:15000});
  
  // console.log(await astronauts.contractBalance())
  // console.log(await ethers.provider.getBalance(user4.address))
  // console.log("User 2 balance :",await astronauts.balanceOf(user2.address))
  // console.log(await astronauts.StakedNFT(user2.address,1))
  // await astronauts.claimFreeInvestorNFTs()   
  
  // console.log(await astronauts.tokenOfOwnerByIndex(user2.address,0)) 
  // console.log(await astronauts.tokenOfOwnerByIndex(user2.address,1)) 
  // console.log(await astronauts.tokenOfOwnerByIndex(user2.address,2)) 
  // console.log(await astronauts.tokenOfOwnerByIndex(user2.address,3)) 
  // console.log(await astronauts.tokenOfOwnerByIndex(user2.address,4)) 
  // console.log(await astronauts.tokenOfOwnerByIndex(user2.address,5))  
  // console.log(await astronauts.tokenOfOwnerByIndex(user2.address,6))  
  
  // await astronauts.connect(user2).stakeInvestorNFT([1,2]) 
  // await astronauts.connect(user2).MintInvestorNFTs(user2.address,1,{value:15000});
  
  // await astronauts.connect(user2).unstakeInvestorNFT([1]) 
  // await astronauts.connect(user2).transferFrom(user2.address,user3.address,1);
  // await astronauts.connect(user2).MintInvestorNFTs(user2.address,1,{value:15000});
  // await astronauts.connect(user3).transferFrom(user3.address,user2.address,1);
  // console.log("--")

  // console.log(await astronauts.tokenOfOwnerByIndex(user2.address,0)) 
  // console.log(await astronauts.tokenOfOwnerByIndex(user2.address,1)) 
  // console.log(await astronauts.tokenOfOwnerByIndex(user2.address,2)) 
  // console.log(await astronauts.tokenOfOwnerByIndex(user2.address,3)) 
  // console.log(await astronauts.tokenOfOwnerByIndex(user2.address,4)) 
  // console.log(await astronauts.tokenOfOwnerByIndex(user2.address,5)) 
  // console.log(await astronauts.tokenOfOwnerByIndex(user2.address,6)) 
  // console.log(await astronauts.tokenOfOwnerByIndex(user2.address,7)) 
  // await astronauts.connect(user2).unstakeInvestorNFT([1,3]) 

  // console.log(await astronauts.balanceOf(user2.address))
  // await astronauts.connect(user2).transferFrom(user2.address,user1.address,2);
  // console.log(await astronauts.balanceOf(user2.address))
  
  // console.log(await astronauts.StakedNFT(user2.address,1))
  // console.log(await astronauts.StakedNFT(user2.address,2))
  // console.log(await astronauts.StakedNFT(user2.address,3))
  // console.log(await astronauts.StakedNFT(user2.address,6))
  // console.log(await astronauts.StakedNFT(user2.address,7)) 
  
  
  // console.log("--")
  // console.log(await astronauts.tokenOfOwnerByIndex(user2.address,0))
  // console.log(await astronauts.tokenOfOwnerByIndex(user2.address,1))
  // console.log(await astronauts.tokenOfOwnerByIndex(user2.address,2))
  // console.log(await astronauts.tokenOfOwnerByIndex(user2.address,3)) 
  // console.log(await astronauts.tokenOfOwnerByIndex(user2.address,4))
  // console.log(await astronauts.tokenOfOwnerByIndex(user2.address,5)) 
  // console.log(await astronauts.tokenOfOwnerByIndex(user2.address,6)) 

  // console.log(await astronauts.ownerOf(0))
  // console.log(await astronauts.ownerOf(1))
  // console.log(await astronauts.ownerOf(2))
  // console.log(await astronauts.ownerOf(3))
  // console.log(await astronauts.ownerOf(4))
  // console.log("Total Supply :",await astronauts.totalSupply())

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


// npx hardhat --network matic run ./scripts/astronauts.deploy.js 
// npx hardhat verify --contract contracts/Astronauts.sol:Astronauts --network matic 0x33299E27b7f7caB765d048fA9A1E8Dfeb499C550

