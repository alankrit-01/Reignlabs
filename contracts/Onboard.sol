// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
// import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";

abstract contract ERC1155Burnable is ERC1155 {
    function burn(
        address account,
        uint256 id,
        uint256 value
    ) public virtual {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not token owner or approved"
        );

        _burn(account, id, value);
    }
}

contract OnboardReignLabs is ERC1155, Pausable, ERC1155Burnable {
    uint public BasicFee;
    uint public EliteFee;
    uint public ProFee;
    mapping(address=>bool) public Owners;
    mapping(address =>uint) public RevenueSplit;
    address[] public Addresses;

    // Dont have the function to show all basic/pro holder.
    // Burn only contract not holders.

    constructor() ERC1155("") {
        Owners[msg.sender]=true;
        Owners[0x80dCC025a1A8D821e87a310d57feD12A18C25F00]=true;
        BasicFee=140000000000000000;
        EliteFee=740000000000000000;
        ProFee=7400000000000000000;
        RevenueSplit[msg.sender]=500;
        Addresses.push(msg.sender);
        RevenueSplit[0x80dCC025a1A8D821e87a310d57feD12A18C25F00]=500;
        Addresses.push(0x80dCC025a1A8D821e87a310d57feD12A18C25F00);
    }
    
    modifier onlyOwner(){
        require(Owners[msg.sender],"Only owner can call this function");
        _;
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function buyBasic(address _to) public payable{
        require(balanceOf(_to,0)==0 && balanceOf(_to,1)==0 && balanceOf(_to,2)==0,"Account is already a pass holder");
        require(msg.value>=BasicFee,"Insufficient fees provided");
        _mint(_to, 0, 1, "0x00");
    }

    // existingPass =0 basic pass
    // existingPass =1 No pass
    function buyElite(address _to, uint existingPass) public payable{
        require(existingPass==0 || existingPass ==1,"Invalid existingPass value 0/1");
        require(balanceOf(_to,1)==0 ,"Account is already an elite pass holder");
        require(balanceOf(_to,2)==0,"Account is already a pro pass holder");
        if(existingPass==1){
            require(balanceOf(_to,0)==0,"Account is already a basic pass holder");
            require(msg.value>=EliteFee,"Insufficient fees provided");
            _mint(_to, 1, 1, "0x00");
        }else if(existingPass==0){
            require(balanceOf(_to,0)!=0,"Account is not a basic pass holder");
            require(msg.value >=(EliteFee-BasicFee),"Insufficient fees provided");
            // burn(_to,0,1);
            _burn(_to, 0, 1);
            _mint(_to, 1, 1, "0x00");
        }
    }   

    // existingPass =0 basic pass
    // existingPass =1 elite pass
    // existingPass =2 No pass
    function buyPro(address _to, uint existingPass) public payable{
        require(existingPass==0 || existingPass ==1 || existingPass ==2 ,"Invalid existingPass value 0/1/2");
        require(balanceOf(_to,2)==0,"Account is already a pro pass holder");
        if(existingPass==2){
            require(balanceOf(_to,0)==0,"Account is already a basic pass holder");
            require(balanceOf(_to,1)==0,"Account is already a elite pass holder");
            require(msg.value>=ProFee,"Insufficient fees provided");
            _mint(_to, 2, 1, "0x00");
        }else if(existingPass==1){
            require(balanceOf(_to,1)!=0,"Account is not a elite pass holder");
            require(msg.value >=(ProFee-EliteFee),"Insufficient fees provided");
            _burn(_to, 1, 1);
            _mint(_to, 2, 1, "0x00");
        }else if(existingPass==0){
            require(balanceOf(_to,0)!=0,"Account is not a basic pass holder");
            require(msg.value >=(ProFee-BasicFee),"Insufficient fees provided");
            _burn(_to, 0, 1);
            _mint(_to, 2, 1, "0x00");
        }
    }


    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
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
}
