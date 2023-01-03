const { ethers} = require("hardhat");
const helpers = require("@nomicfoundation/hardhat-network-helpers");

async function main() {

//   const [user1,user2,user3,user4,user5,user6,user7,user8,user9,user10] = await ethers.getSigners();
    const impersonatedSigner = await ethers.getImpersonatedSigner("0xE6e75cE302AcF0016d24Dbfbeb34b89aE5d3A036");
    console.log(impersonatedSigner.address)
    let x= await ethers.provider.getBalance(impersonatedSigner.address);
    console.log(x);

    let TheMooseSociety  = await hre.ethers.getContractFactory("TheMooseSociety");
    let MS = TheMooseSociety.attach("0xF63063bB20a03B85Bd08d5C1244AF8bA0aEE1B1F");

    let AstroNAUTS  = await hre.ethers.getContractFactory("Astronauts");
    let astroNAUTS = AstroNAUTS.attach("0x508e863F8F3be3fA1a863CB4aAC0E45f0A45B217");

    // await astroNAUTS.connect(impersonatedSigner).claimFreeInvestorNFTs();
    // await astroNAUTS.connect(impersonatedSigner).claimFreeInvestorNFTs();

    console.log(await astroNAUTS.balanceOf(impersonatedSigner.address));

  
  // const Test1 = await ethers.getContractFactory("MooseSociety");
  // const test1 = await Test1.deploy();
  
  // await test1.deployed();
  // console.log(`Test1 contracts deployed to ${test1.address}`);
  // // 0xC0485b2005a6840180937A7cc6b89BBed2281b94

  // const Test2 = await ethers.getContractFactory("AlphaIsand");
  // const test2 = await Test2.deploy();
  
  // await test2.deployed();
  // console.log(`Test2 contracts deployed to ${test2.address}`);
  // // 0x91133E3BB20a9183eED2c9cf8DaD28D2d268BACb

  // const Test3 = await ethers.getContractFactory("GROUCHYTIGERS");
  // const test3 = await Test3.deploy();
  
  // await test3.deployed();
  // console.log(`Test3 contracts deployed to ${test3.address}`);
  // 0x6bf946A39701f8A2eb5F33e31F4D092eb8ed90D9

//   const Astronauts = await ethers.getContractFactory("Astronauts");
//   const astronauts = await Astronauts.deploy();
  // const astronauts = await Astronauts.deploy(test1.address,test2.address);
//   await astronauts.deployed();      
//   console.log(`AstroNAUTS contracts deployed to ${astronauts.address}`);
  // 0x77c6f11c4f04C1Fd9b84A76DfE42a4FE293cA6d1

  // await test1.safeMint(user2.address,1);
  // await test1.safeMint(user4.address,2);
  // await test1.safeMint(user5.address,3);
  // await test1.safeMint(user6.address,4);
  // await test1.safeMint(user7.address,5);

  // await test2.safeMint(user3.address,1);
  // await test2.safeMint(user3.address,3);
  // await test2.safeMint(user4.address,2);
  // await test2.safeMint(user5.address,4);
  // await test2.safeMint(user6.address,5);
  // await test2.safeMint(user7.address,6);


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


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});


// npx hardhat --network matic run ./scripts/astronauts.deploy.js 
// npx hardhat verify --contract contracts/Astronauts.sol:Astronauts --network matic 0x77c6f11c4f04C1Fd9b84A76DfE42a4FE293cA6d1

