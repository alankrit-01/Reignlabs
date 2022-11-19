// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";

contract MyToken is ERC721, EIP712, Ownable {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    string private constant SIGNING_DOMAIN ="WEB3CLUB";
    string private constant SIGNATURE_VERSION = "1"; 

    constructor() ERC721("MyToken" , "MTK") EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION) {}

    function safeMint(address to, uint256 id, string memory name, bytes memory signature) public {
        require(check(id, name, signature) == owner(), "Voucher invalid");
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        _safeMint(to, tokenId) ;
    }

    function check(uint256 id , string memory name, bytes memory signature) public view returns (address) {
        return _verify( id , name, signature);
    }

    function _verify(uint256 id, string memory name, bytes memory signature) internal view returns (address) {
        bytes32 digest =_hash(id,name);
        return ECDSA.recover(digest, signature);
    }

    function _hash(uint256 id , string memory name) internal view returns (bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(   
        keccak256( "Web3Struct(uint256 id ,string name)"),
        id,
        keccak256(bytes(name))
        // keccak256(bytes( STRING) ) for string
        )));
    }
}
// 