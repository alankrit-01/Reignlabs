// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Test2 is ERC721, Ownable {
    constructor() ERC721("Test2", "MTK") {
        _safeMint(msg.sender, 0);
        _safeMint(0x90F79bf6EB2c4f870365E785982E1f101E93b906, 1);
    }

    function safeMint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
    }
}
