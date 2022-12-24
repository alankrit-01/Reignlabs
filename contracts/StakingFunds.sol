// SPDX-License-Identifier: MIT   
pragma solidity ^0.8.9;            

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract ERC721Holder is IERC721Receiver {
  function onERC721Received(address, address, uint256, bytes memory) public pure returns(bytes4){
    return this.onERC721Received.selector;
  }
}   
// TODO:

// DISCUSS :                                                  
// FINAL DISCUSS-                                             
// DONE free mint is per wallet not per NFT                  
// what if holders transfer their NFTs ???????????????????    


// ERC721 base contract updated wont work on remix
// Update PAUSE FUNCTION

// Make it pausable
// MintDiscountedInvestorNFTs require(amount<20);

// GOAL:
// only signature that comes from the database should be used
// timestamp on signature to when it is available

// user mint then stake 
// t0 ->staked, availabe to claim -0
// t1 ->avalible to claim -$7 pass the signature in claim function claimed, signature can not be used
// update claimed till now  

// ---------------------------------
// IMPORTANT                        
// 1- Change in base ERC721 contract
// 2- Change in counter library     
// 3- Reignlabs wallet to be replaced with the MultiSig wallet
// --------------------------------- 

                       

contract StakingFunds is EIP712{
    mapping(address=>bool) public validator;
    bool public contractPaused;                             
    string private constant SIGNING_DOMAIN ="ASTRONAUTS";
    string private constant SIGNATURE_VERSION = "1";    
    mapping(uint256 =>bool) public redeemedIDs;  
    address public ReignLabsWallet;                        

    mapping(address => uint256) public claimedSoFar;

    constructor() EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION)
    payable
    {
        ReignLabsWallet =0xC0485b2005a6840180937A7cc6b89BBed2281b94;                        
        validator[msg.sender]=true;         
    }                                    

    receive() external payable {}     

    modifier onlyValidator() {
        require(validator[msg.sender]==true,"Only a validator can call this function");
        _;
    }

    modifier whenNotPaused(){
        require(contractPaused==false,"Contract is in paused state");
        _;
    }

    function claimInvestorRewards
        (
            uint256 uniqueID, 
            uint _MaxtimeStamp, 
            uint256 claimAmount, 
            address _address, 
            bytes memory signature
        ) 
            public payable whenNotPaused
        {

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
    function removeValidator(address _address) public onlyValidator{
        require(validator[msg.sender]==true,"Not a validator");
        validator[_address]=false;
    }               

    // Tested 
    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }       

    function getTimeStamp() public view returns(uint256){
        return block.timestamp;
    }        

    // Tested 
    function withdrawEthers(uint amount) public onlyValidator {
        (bool success, ) = (ReignLabsWallet).call{value: amount}("");
        require(success, "Failed to send ethers");
    }          

    function pauseUnpauseContract(bool pause) public onlyValidator{
        contractPaused=pause;
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
