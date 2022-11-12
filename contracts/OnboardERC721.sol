// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";

// Talk about :
// -two owners!
// -timstap in signature
// NUMBERS of giveaway
// Givaway batch function   

contract OnboardReignLabs is ERC721,EIP712, Pausable {
    uint16 public basicId=1;
    uint16 public basicCap=4500;
    uint16 public basicGAId=4501;
    uint16 public basicGACap=5000;

    uint16 public eliteId=5001;
    uint16 public eliteCap=7700;
    uint16 public eliteGAId=7701;
    uint16 public eliteGACap=8000;

    uint16 public proId=8001;
    uint16 public proCap=9800;
    uint16 public proGAId=9801;
    uint16 public proGACap=10000;

    uint public BasicFee; 
    uint public EliteFee;
    uint public ProFee;
    
    string private constant SIGNING_DOMAIN ="REIGNLABS";
    string private constant SIGNATURE_VERSION = "1"; 
    mapping(uint256 =>bool) redeemed;
    mapping(address =>uint) public RevenueSplit;
    address[] public Addresses;
    address[] public Owners;
    string public baseURI = "https://blank.herokuapp.com/api/";

    constructor() ERC721("OnboardReignLabs", "RLabs") EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION) {
        Owners.push(msg.sender);
        Owners.push(0x80dCC025a1A8D821e87a310d57feD12A18C25F00);
        BasicFee=100000000000000;
        EliteFee=200000000000000;
        ProFee=300000000000000;
        RevenueSplit[msg.sender]=500;
        Addresses.push(msg.sender);
        RevenueSplit[0x80dCC025a1A8D821e87a310d57feD12A18C25F00]=500;
        Addresses.push(0x80dCC025a1A8D821e87a310d57feD12A18C25F00);
    }

    modifier onlyOwner(){
        require(isOwner(msg.sender),"Only the owner can call this function");
        _;
    }

    function isOwner(address _address) internal view returns(bool){
        for(uint i=0; i< Owners.length; i++){
            if(Owners[i]==_address) return true;
        }
        return false;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    
    // _type =0 for basic pass
    // _type =1 for elite pass
    // _type =2 for pro pass
    function buyTokenPass(address _to, uint _type) public payable{
        require(_type==0 || _type==1 || _type==2 ,"Invalid _type argument");
        if(_type==0){
            require(basicId<=basicCap,"Basic token cap reached");
            require(msg.value>=BasicFee,"Insufficient fees provided");
            _safeMint(_to, basicId);
            basicId++;
        }else if(_type==1){
            require(eliteId<=eliteCap,"Elite token cap reached");
            require(msg.value>=EliteFee,"Insufficient fees provided");
            _safeMint(_to, eliteId);
            eliteId++;
        }else if(_type==2){
            require(proId<=proCap,"Pro token cap reached");
            require(msg.value>=ProFee,"Insufficient fees provided");
            _safeMint(_to, proId);
            proId++;
        }
    }

    function giveAwayPass(uint256 id, uint256 _type, address to, bytes memory signature) public {
        require(isOwner(check(id, _type, to, signature)), "Voucher invalid");
        require(redeemed[id]!=true,"Already redeemed!");
        if(_type==0){
            require(basicGAId<=basicGACap,"Basic giveaway token cap reached");
            _safeMint(to, basicGAId);
            basicGAId++;
        }else if(_type==1){
            require(eliteGAId<=eliteGACap,"Elite giveaway token cap reached");
            _safeMint(to, eliteGAId);
            eliteGAId++;
        }else if(_type==2){
            require(proGAId<=proGACap,"Pro giveaway token cap reached");
            _safeMint(to, proGAId);
            proGAId++;
        }
        redeemed[id]=true;
    }

    function _beforeTokenTransfer( address from, address to, uint256 tokenId ) internal override {
        require(from ==address(0),"Soulbound tokens can not be transferred");
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // category =0 for basic fee
    // category =1 for elit fee
    // category =2 for pro fee

    function updatePassPrice(uint category,uint updatedPriceInWei) public onlyOwner{
        require(category==0 ||category==1 || category==2,"Invalid category value");
        if(category==0) BasicFee=updatedPriceInWei;
        else if(category==1) EliteFee=updatedPriceInWei;
        else if(category==2) ProFee=updatedPriceInWei;
    }
    
    // _percentage =percentage*10   
    // eg 60% -> 600    

    function updateRevenueSplits(address _address, uint256 _percentage) public onlyOwner {
        require(!(RevenueSplit[_address]==0 && _percentage==0),"Invalid operation");
        if(RevenueSplit[_address]==0){
            Addresses.push(_address);
        }else if(RevenueSplit[_address]!=0 && _percentage==0){
            for(uint i=0;i<Addresses.length; i++){
                if(Addresses[i]==_address){
                    Addresses[i]=Addresses[Addresses.length-1];
                    Addresses.pop();
                    break;
                }
            }
        }
        RevenueSplit[_address]=_percentage;
    } 
    
    function getRevenueSplitAddresses() public view returns(address[] memory){
        return Addresses;
    }

    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function withDrawEthers() public onlyOwner{
        uint balance =contractBalance();
        for(uint i=0;i<Addresses.length; i++){
            uint amount= (balance*RevenueSplit[Addresses[i]])/1000;
            (bool success, ) = (Addresses[i]).call{value: amount}("");
            require(success, "Failed to send ethers");
        }
    }
    
    function check(uint256 id, uint256 _type, address to, bytes memory signature) public view returns (address) {
        return _verify(id, _type, to, signature);
    }

    function _verify(uint256 id, uint256 _type, address to, bytes memory signature) internal view returns (address) {
        bytes32 digest =_hash(id,_type,to);
        return ECDSA.recover(digest, signature);
    }

    function _hash(uint256 id, uint256 _type, address to) internal view returns (bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(   
        keccak256( "Struct(uint256 id,uint256 _type,address to)"),
        id,
        _type,
        to
        )));
        // keccak256(bytes(name))
        // keccak256(bytes( STRING) ) for string
    }
    
    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function updateBaseUri(string memory _newbaseURI) onlyOwner public {
        baseURI = _newbaseURI;
    }
}


