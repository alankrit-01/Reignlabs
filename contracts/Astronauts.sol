// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;         

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

contract ERC721Holder is IERC721Receiver {
  function onERC721Received(address, address, uint256, bytes memory) public pure returns(bytes4){
    return this.onERC721Received.selector;
  }
}
// TODO:

// DISCUSS :    
// FINAL DISCUSS- 
// free mint is per wallet not per NFT      
// what if holders transfer their NFTs ???????????????????


// ERC721 base contract updated wont work on remix


// Make it pausable
// MintDiscountedInvestorNFTs require(amount<20);

// GOAL:
// only signature that comes from the database should be used
// timestamp on signature to when it is available

// user mint then stake
// t0 ->staked, availabe to claim -0
// t1 ->avalible to claim -$7 pass the signature in claim function claimed, signature can not be used
// update claimed till now

interface NFTContract {    
    function balanceOf(address owner) external view returns (uint256 balance);
}   


contract Astronauts is ERC721 ,EIP712, IERC721Receiver,ERC721Holder{
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    uint256 public NFTprice;
    uint256 public DiscountedNFTprice;
    uint256 public NFTcap;
    address public ReignLabsWallet;
    mapping(address=>bool) public validator;
    address public MooseSociety;
    address public AlphaHeard;
    bool discountPaused;
    
    address[] public NFTProjects; 

    mapping(address=>bool) public claimedMoose;
    mapping(address=>bool) public claimedAlpha; 

    string private constant SIGNING_DOMAIN ="ASTRONAUTS";
    string private constant SIGNATURE_VERSION = "1";    
    mapping(uint256 =>bool) public redeemedIDs;  

    // struct StakedMetaData{   
    //     address owner;       
    //     uint timeStamp;      
    // }                         

    mapping(address => mapping(uint256 =>bool)) public StakedNFT;
    mapping(address => uint256) public claimedSoFar;
    // mapping(uint=>StakedMetaData) public StakedNFTbyId;    
    // uint dispersalCounter;

    constructor() ERC721("Astronauts", "ASTRO") EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION){
        // MooseSociety=mooseSociety;
        // AlphaHeard=alphaHeard;
        ReignLabsWallet=0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
        validator[msg.sender]=true;         
        NFTprice =150;    
        DiscountedNFTprice =110;    
        NFTcap=1000;   
        // NFTProjects.push(mooseSociety);
        // NFTProjects.push(alphaHeard);
    }   

    receive() external payable {} 
    
    modifier onlyValidator() {
        require(validator[msg.sender]==true,"Only a validator can call this function");
        _;
    }

    // CAUTION: Wont be used in production
    function addFreeMintAddresses(address mooseSociety,address alphaHeard) public onlyValidator{
        MooseSociety=mooseSociety;
        AlphaHeard=alphaHeard;
    }

    // Tested 
    function claimFreeInvestorNFTs() public{
        uint256 tokenId = _tokenIdCounter.current();
        uint amount;                                 
        if((claimedMoose[msg.sender]==false && NFTContract(MooseSociety).balanceOf(msg.sender)>0) && (claimedAlpha[msg.sender]==false && NFTContract(AlphaHeard).balanceOf(msg.sender)>0)){
            amount=6;
            claimedMoose[msg.sender]=true;
            claimedAlpha[msg.sender]=true;
        }else if(claimedMoose[msg.sender]==false && NFTContract(MooseSociety).balanceOf(msg.sender)>0){
            amount=1;      
            claimedMoose[msg.sender]=true;
        }else if(claimedAlpha[msg.sender]==false && NFTContract(AlphaHeard).balanceOf(msg.sender)>0){
            amount=5;
            claimedAlpha[msg.sender]=true;
        }else{
            revert("Can't claim free Investors NFTs");
        }
        require(tokenId+amount<=NFTcap,"Maximum cap reached for asto-nauts NFTs");
        for(uint i=0; i<amount; i++){
            uint256 tokenIdlocal = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            _safeMint(msg.sender, tokenIdlocal);
        }
    }   

    // Tested   
    function MintInvestorNFTs(address to, uint amount) public payable{
        uint256 tokenId = _tokenIdCounter.current();
        require(tokenId+amount<=NFTcap,"Maximum cap reached for asto-nauts NFTs");
        if(validator[msg.sender]==false){
            require(msg.value>=NFTprice*amount,"Please send sufficient amount of ethers");
        }
        for(uint i=0; i<amount; i++){
            uint256 tokenIdlocal = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            _safeMint(to, tokenIdlocal);
        }
    }

    // Tested   
    function MintDiscountedInvestorNFTs(address to, uint amount) public payable {
        require(discountPaused==false,"Discounted mint function is currently paused");
        require(amount<=50);
        bool isHolder;
        uint256 tokenId = _tokenIdCounter.current();
        for(uint i=0; i<NFTProjects.length; i++){
            if(NFTProjects[i]== address(0)) continue;
            if(NFTContract(NFTProjects[i]).balanceOf(msg.sender)>0){
                isHolder=true;
                break;
            }
        }   
        require(isHolder==true,"Caller can't mint discounted NFTs");
        require(msg.value>= DiscountedNFTprice*amount ,"Please send sufficient amount of ethers");
        require(tokenId+amount<=NFTcap,"Maximum cap reached for asto-nauts NFTs");
        for(uint i=0; i<amount; i++){
            uint256 tokenIdlocal = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            _safeMint(to, tokenIdlocal);
        }
    } 

    function stakeInvestorNFT(uint tokenId) public {
        require(StakedNFT[msg.sender][tokenId]==false);
        require(ownerOf(tokenId)==msg.sender,"Not the Owner of this tokenID");
        safeTransferFrom(msg.sender,address(this),tokenId);
        StakedNFT[msg.sender][tokenId]=true;
        StakedNFTbyId[tokenId]=StakedMetaData({owner:msg.sender,timeStamp:block.timestamp});
    }           

    function unstakeInvestorNFT(uint tokenId) public {
        require(StakedNFT[msg.sender][tokenId]==true,"TokenID not staked");
        safeTransferFrom(address(this),msg.sender,tokenId);
        StakedNFT[msg.sender][tokenId]=false;
        StakedNFTbyId[tokenId]=StakedMetaData({owner:address(0),timeStamp:0});
    }       

    function calimInvestorRewards(uint256 uniqueID, uint _MaxtimeStamp, uint256 claimAmount, address _address, bytes memory signature) public payable{
        // require(balanceOf(msg.sender)>0);
        require(redeemedIDs[uniqueID]!=true,"Already redeemed!");
        require(block.timestamp<=_MaxtimeStamp,"Time limit exceed to redeem this signature");                   
        address temp =check(uniqueID,_MaxtimeStamp, claimAmount, _address, signature);  
        require(validator[temp]==true,"Voucher invalid");
        uint amount = claimAmount-claimedSoFar[msg.sender];
        (bool success, ) = (msg.sender).call{value: amount}("");
        require(success, "Failed to send ethers");
        claimedSoFar[msg.sender]=claimAmount;
        redeemedIDs[uniqueID]=true;
    }

    // Tested 
    function addValidator(address _address) public onlyValidator{
        require(validator[_address]==false,"Already a validator");
        validator[_address]=true;
    }   

    // Tested 
    function addNFTProject(address _address) public onlyValidator{
        require(_address!=address(0),"Invalid address");
        for(uint i=0; i<NFTProjects.length; i++){
            require(NFTProjects[i]!=_address,"Project address already exists in the list");
        }                                      
        NFTProjects.push(_address);           
    } 

    // Tested 
    function removeNFTProject(address _address) public onlyValidator{
        for(uint i=0;i<NFTProjects.length; i++){
            if(NFTProjects[i]==_address) { 
                delete NFTProjects[i];
                break;
            }
        }
    }

    // Tested 
    function removeValidator(address _address) public onlyValidator{
        require(validator[msg.sender]==true,"Not a validator");
        validator[_address]=false;
    }

    // Tested 
    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }  

    // Tested 
    function totalSupply() public view returns(uint256){
        uint256 tokenId = _tokenIdCounter.current();
        return tokenId;
    }

    function getTimeStamp() public view returns(uint256){
        return block.timestamp;
    }

    // Tested 
    function withdrawEthers(uint amount) public onlyValidator {
        (bool success, ) = (ReignLabsWallet).call{value: amount}("");
        require(success, "Failed to send ethers");
    }

    // Tested 
    function updtateNFTPice(bool discounted, uint price) public onlyValidator{
        if(discounted){
            DiscountedNFTprice=price;
        }else{
            NFTprice=price;
        }
    }

    // Tested 
    function pauseUnpauseDiscountMint(bool pause) public onlyValidator{
        discountPaused=pause;
    }

    function check(uint256 id, uint256 _MaxtimeStamp, uint256 claimAmount, address _address, bytes memory signature) public view returns (address) {
        return _verify(id,_MaxtimeStamp, claimAmount, _address, signature);
    }

    function _verify(uint256 id, uint256 _MaxtimeStamp, uint256 claimAmount, address _address, bytes memory signature) internal view returns (address) {
        bytes32 digest =_hash(id,_MaxtimeStamp,claimAmount,_address);
        return ECDSA.recover(digest, signature);
    }

    function _hash(uint256 id, uint256 _MaxtimeStamp, uint256 claimAmount, address _address) internal view returns (bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(   
        keccak256( "Struct(uint256 id,uint256 _MaxtimeStamp,uint256 claimAmount,address _address)"),
        id,
        _MaxtimeStamp,
        claimAmount,
        _address
        )));
        // keccak256(bytes(name))
        // keccak256(bytes( STRING) ) for string
    }

}
