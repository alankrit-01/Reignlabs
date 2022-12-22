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

interface NFTContract {    
    function balanceOf(address owner) external view returns (uint256 balance);
}   

contract Astronauts is ERC721, EIP712, IERC721Receiver,ERC721Holder{
    using Counters for Counters.Counter;        

    Counters.Counter private _tokenIdCounter;
    uint256 public NFTprice;
    uint256 public DiscountedNFTprice;
    uint256 public NFTcap;      
    address public ReignLabsWallet;
    address public MultiSigWallet;
    mapping(address=>bool) public validator;
    address public MooseSociety;
    address public AlphaHeard;   
     
    bool public discountPaused; 
    bool public claimPaused;    
    bool public contractPaused;  

    address[] public NFTProjects;               
                                                
    mapping(address=>bool) public claimedMoose; 
    mapping(address=>bool) public claimedAlpha; 
    uint public constant MooseCap =100;         
    uint public constant AlphaCap =30;          
    uint public MooseCount;                     
    uint public AlphaCount;                     
                                                 
    string private constant SIGNING_DOMAIN ="ASTRONAUTS";
    string private constant SIGNATURE_VERSION = "1";    
    mapping(uint256 =>bool) public redeemedIDs;  

    // struct StakedMetaData{   
    //     address owner;       
    //     uint timeStamp;      
    // }           

    // multiple staking and multiple unstaking tokenId;
    // Listing of minted nft per wallet         
    // list of staked nfts per wallet   

    mapping(address => mapping(uint256 =>bool)) public StakedNFT;
    mapping(address => uint256) public claimedSoFar;
    // mapping(uint=>StakedMetaData) public StakedNFTbyId;    
    // uint dispersalCounter;
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;
    mapping(uint256 => uint256) private _ownedTokensIndex;
    uint256[] private _allTokens;
    mapping(uint256 => uint256) private _allTokensIndex;

    constructor() ERC721("Astronauts", "ASTRO") EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION)
    payable
    {
        MooseSociety=0xC0485b2005a6840180937A7cc6b89BBed2281b94; // Moose Society address
        AlphaHeard=0x91133E3BB20a9183eED2c9cf8DaD28D2d268BACb;   // Alpha Island address
                                                                                
        ReignLabsWallet=0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;  // To transfer the funds from this wallet
        MultiSigWallet=0x90F79bf6EB2c4f870365E785982E1f101E93b906;  // To transfer the funds from this wallet
                                                                                
        validator[msg.sender]=true;         
        NFTprice =150;                
        DiscountedNFTprice =110;      
        NFTcap=1969;                  
        NFTProjects.push(0xC0485b2005a6840180937A7cc6b89BBed2281b94); // Moose Society address
        NFTProjects.push(0x91133E3BB20a9183eED2c9cf8DaD28D2d268BACb); // Alpha Island address
        NFTProjects.push(0x6bf946A39701f8A2eb5F33e31F4D092eb8ed90D9); // Grouchy tigers     
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

    // CAUTION: Don't use this in production
    function addFreeMintAddresses(address mooseSociety,address alphaHeard) public onlyValidator{
        MooseSociety=mooseSociety;
        AlphaHeard=alphaHeard;
    }

    // Tested 
    function claimFreeInvestorNFTs() public whenNotPaused{
        require(MooseCount<MooseCap);
        require((AlphaCount+1)<AlphaCap);
        uint256 tokenId = _tokenIdCounter.current();
        uint amount;                                 
        if((claimedMoose[msg.sender]==false && NFTContract(MooseSociety).balanceOf(msg.sender)>0) && (claimedAlpha[msg.sender]==false && NFTContract(AlphaHeard).balanceOf(msg.sender)>0)){
            amount=3;
            claimedMoose[msg.sender]=true;
            claimedAlpha[msg.sender]=true;
            MooseCount++;
            AlphaCount+=2;

        }else if(claimedMoose[msg.sender]==false && NFTContract(MooseSociety).balanceOf(msg.sender)>0){
            amount=1;      
            claimedMoose[msg.sender]=true;
            MooseCount++;
        }else if(claimedAlpha[msg.sender]==false && NFTContract(AlphaHeard).balanceOf(msg.sender)>0){
            amount=2;
            claimedAlpha[msg.sender]=true;
            AlphaCount+=2;
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
    function MintInvestorNFTs(address to, uint amount) public whenNotPaused payable{
        uint256 tokenId = _tokenIdCounter.current();
        require(tokenId+amount<=NFTcap,"Maximum cap reached for asto-nauts NFTs");
        if(validator[msg.sender]==false){
            require(msg.value>=NFTprice*amount,"Please send sufficient amount of ethers");
            (bool success, ) = (MultiSigWallet).call{value: msg.value}("");
            require(success, "Failed to send ethers");
        }
        for(uint i=0; i<amount; i++){
            uint256 tokenIdlocal = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            _safeMint(to, tokenIdlocal);
        }
    }   

    // Tested   
    function MintDiscountedInvestorNFTs(address to, uint amount) public whenNotPaused payable {
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
        
        (bool success, ) = (MultiSigWallet).call{value: msg.value}("");
        require(success, "Failed to send ethers");

        require(tokenId+amount<=NFTcap,"Maximum cap reached for asto-nauts NFTs");
        for(uint i=0; i<amount; i++){
            uint256 tokenIdlocal = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            _safeMint(to, tokenIdlocal);
        }
    } 

    function stakeInvestorNFT(uint[] memory tokenIDs) public whenNotPaused {
        for(uint i=0; i<tokenIDs.length; i++){
            require(StakedNFT[msg.sender][tokenIDs[i]]==false);
            require(ownerOf(tokenIDs[i])==msg.sender,"Not the Owner of this tokenID");
            safeTransferFrom(msg.sender,address(this),tokenIDs[i]);
            StakedNFT[msg.sender][tokenIDs[i]]=true;
            StakedNFTbyId[tokenIDs[i]]=StakedMetaData({owner:msg.sender,timeStamp:block.timestamp});
        }
    }    

    function unstakeInvestorNFT(uint[] memory tokenIDs) public whenNotPaused{     
        for(uint i=0; i<tokenIDs.length; i++){
            require(StakedNFT[msg.sender][tokenIDs[i]]==true,"TokenID not staked");     
            safeTransferFrom(address(this),msg.sender,tokenIDs[i]);                     
            StakedNFT[msg.sender][tokenIDs[i]]=false;                                   
            StakedNFTbyId[tokenIDs[i]]=StakedMetaData({owner:address(0),timeStamp:0});  
        }
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
        // require(balanceOf(msg.sender)>0);
        require(claimPaused==false,"Claim Investor rewards function is currently paused");

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

    function pauseUnpauseClaimInvestorRewards(bool pause) public onlyValidator{
        claimPaused=pause;
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

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view virtual returns (uint256) {
        return (_tokenIdCounter.current()-1);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId
    ) internal override virtual {
        super._beforeTokenTransfer(from, to, firstTokenId);

        uint256 tokenId = firstTokenId;

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }    
}
