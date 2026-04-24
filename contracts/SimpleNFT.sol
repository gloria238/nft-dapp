// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SimpleNFT is ERC721URIStorage, Ownable {
    uint256 public mintPrice = 0.01 ether;
    uint256 public nextTokenId;

    event Minted(address indexed to, uint256 indexed tokenId, string tokenURI);

    constructor() ERC721("SimpleNFT", "SNFT") Ownable(msg.sender) {}

    function mint(string memory tokenURI) external payable {
        require(msg.value >= mintPrice, "Insufficient payment");

        // 多付退款
        uint256 excess = msg.value - mintPrice;
        if (excess > 0) {
            payable(msg.sender).transfer(excess);
        }

        uint256 tokenId = nextTokenId;
        nextTokenId++;

        _mint(msg.sender, tokenId);
        _setTokenURI(tokenId, tokenURI);

        emit Minted(msg.sender, tokenId, tokenURI);
    }

    function setMintPrice(uint256 newPrice) external onlyOwner {
        mintPrice = newPrice;
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "Nothing to withdraw");
        payable(owner()).transfer(balance);
    }
}
