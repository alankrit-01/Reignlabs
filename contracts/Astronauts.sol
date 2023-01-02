// SPDX-License-Identifier: MIT   
pragma solidity ^0.8.9;            

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";  
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";    
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";  


contract ERC721Holder is IERC721Receiver {
  function onERC721Received(address, address, uint256, bytes memory) public pure returns(bytes4){
    return this.onERC721Received.selector;
  } 
}    

interface NFTContract {     
    function balanceOf(address owner) external view returns (uint256 balance);
}                            

contract Astronauts is ERC721, IERC721Receiver,ERC721Holder{
    using Counters for Counters.Counter;                            
        
    Counters.Counter private _tokenIdCounter;              
    uint256 public NFTprice;        
    uint256 public DiscountedNFTprice;      

    uint32 public NFTcap;      
    uint32 public constant MooseCap =100;         
    uint32 public constant AlphaCap =32;          
    uint32 public MooseCount;                     
    uint32 public AlphaCount;    

    bool public discountPaused; 
    bool public contractPaused;  

    address public MultiSigWallet;      
    address public MooseSociety;    
    address public AlphaHeard;       
                                                
    address[] public NFTProjects;               
    uint256[] private _allTokens;                   
    mapping(address=>bool) public validator;    
    mapping(address=>bool) public claimedMoose; 
    mapping(address=>bool) public claimedAlpha; 
    mapping(address => mapping(uint256 =>bool)) public StakedNFT;
    mapping(address => uint256) public claimedSoFar;
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;
    mapping(uint256 => uint256) private _ownedTokensIndex;
    mapping(uint256 => uint256) private _allTokensIndex;

    string public baseURI = "https://reignkit.reignlabs.io/api/nauts/"; 

    // struct StakedMetaData{   
    //     address owner;       
    //     uint timeStamp;      
    // }                         
    // mapping(uint=>StakedMetaData) public StakedNFTbyId; 
                           
    constructor() ERC721("Astronauts", "ASTRO") payable{
        MooseSociety=0xF63063bB20a03B85Bd08d5C1244AF8bA0aEE1B1F; // Moose Society address
        AlphaHeard=0x24A913B00cbC8C3c747B19C7944E4dA26da1130b;   // Alpha Island address
                                                                                
        MultiSigWallet=0x80dCC025a1A8D821e87a310d57feD12A18C25F00;  // To transfer the funds from this wallet
                                                                    
        validator[msg.sender]=true;   
        validator[0x03717989289c46a101A18b0A3e0Ca8DffB92a5a5] =true;      
        NFTprice =82169269000000000;   // $100             
        DiscountedNFTprice =110;      
        NFTcap=1970;                    
        NFTProjects.push(0xF63063bB20a03B85Bd08d5C1244AF8bA0aEE1B1F); // Moose Society address
        NFTProjects.push(0x24A913B00cbC8C3c747B19C7944E4dA26da1130b); // Alpha Island address
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

    function claimFreeInvestorNFTs() public whenNotPaused {
        require(MooseCount<MooseCap,"Moose cap reached");
        require((AlphaCount+1)<AlphaCap,"Alpha cap reached");
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
  
    function MintDiscountedInvestorNFTs(address to, uint amount) public whenNotPaused payable {
        require(discountPaused==false,"Discounted mint function is currently paused");
        // require(amount<=50,"Please pass a value less then 50");
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
            require(StakedNFT[msg.sender][tokenIDs[i]]==false,"Already Staked");
            require(ownerOf(tokenIDs[i])==msg.sender,"Not the Owner of this tokenID");
            // safeTransferFrom(msg.sender,address(this),tokenIDs[i]);
            StakedNFT[msg.sender][tokenIDs[i]]=true;
            StakedNFTbyId[tokenIDs[i]]=StakedMetaData({owner:msg.sender,timeStamp:block.timestamp});
        }
    }       

    function unstakeInvestorNFT(uint[] memory tokenIDs) public whenNotPaused{     
        for(uint i=0; i<tokenIDs.length; i++){
            require(StakedNFT[msg.sender][tokenIDs[i]]==true,"TokenID not staked");     
            // safeTransferFrom(address(this),msg.sender,tokenIDs[i]);                     
            StakedNFT[msg.sender][tokenIDs[i]]=false;                                   
            StakedNFTbyId[tokenIDs[i]]=StakedMetaData({owner:address(0),timeStamp:0});  
        }
    }     

    function addValidator(address _address) public onlyValidator{
        require(validator[_address]==false,"Already a validator");
        validator[_address]=true;
    }   

    function addNFTProject(address _address) public onlyValidator{
        require(_address!=address(0),"Invalid address");
        for(uint i=0; i<NFTProjects.length; i++){
            require(NFTProjects[i]!=_address,"Project address already exists in the list");
        }                                      
        NFTProjects.push(_address);           
    } 

    function removeNFTProject(address _address) public onlyValidator{
        for(uint i=0;i<NFTProjects.length; i++){
            if(NFTProjects[i]==_address) { 
                delete NFTProjects[i];
                break;
            }
        }
    }

    function removeValidator(address _address) public onlyValidator{
        require(validator[msg.sender]==true,"Not a validator");
        validator[_address]=false;
    }               

    function burn(uint256 tokenId) public virtual {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        _burn(tokenId);
    }

    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }       

    function getTimeStamp() public view returns(uint256){
        return block.timestamp;
    }        

    function withdrawEthers(uint amount) public onlyValidator {
        (bool success, ) = (MultiSigWallet).call{value: amount}("");
        require(success, "Failed to send ethers");
    }

    function updtateNFTPice(bool discounted, uint price) public onlyValidator{
        if(discounted){
            DiscountedNFTprice=price;
        }else{
            NFTprice=price;
        }
    }   

    function pauseUnpauseDiscountMint(bool pause) public onlyValidator{
        discountPaused=pause;
    }

    function pauseUnpauseContract(bool pause) public onlyValidator{
        contractPaused=pause;
    }
        
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        // if(_ownedTokens[owner][index]==0){
        //     revert("ERC721Enumerable: owner index out of bounds");
        // }                                  
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view virtual returns (uint256) {
        return _allTokens.length;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function updateBaseUri(string memory _newbaseURI) onlyValidator public {
        baseURI = _newbaseURI;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId
    ) internal override virtual {
        super._beforeTokenTransfer(from, to, firstTokenId);
        require(StakedNFT[msg.sender][firstTokenId]==false,"Staked NFTs are soulbounded");
        uint256 tokenId = firstTokenId;
        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } 
        else if ((from != to)) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if ((to != from)) {
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
