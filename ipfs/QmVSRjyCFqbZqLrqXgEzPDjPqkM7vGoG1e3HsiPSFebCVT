// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol";

contract SimPLnftdrop is ERC721, ReentrancyGuard {
    address public owner;
    uint256 public totalSupply;
    uint256 public maxSupply;
    uint256 public price;
    string public baseURI;
    bool public dropEnabled;
    
    constructor(string memory _name, string memory _symbol, string memory _baseURI, uint256 _maxSupply, uint256 _price) ERC721(_name, _symbol) {
        owner = msg.sender;
        baseURI = _baseURI;
        maxSupply = _maxSupply;
        price = _price;
    }
    
    function startDrop() public onlyOwner {
        dropEnabled = true;
    }
    
    function stopDrop() public onlyOwner {
        dropEnabled = false;
    }
    
    function mint(address to) public payable nonReentrant {
        require(dropEnabled, "NFT drop is not enabled");
        require(totalSupply < maxSupply, "Maximum supply reached");
        require(msg.value >= price, "Insufficient payment");
        uint256 newTokenId = totalSupply + 1;
        _safeMint(to, newTokenId);
        totalSupply += 1;
    }
    
    function setBaseURI(string memory _baseURI) public onlyOwner {
        baseURI = _baseURI;
    }
    
    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    receive() external payable {}
}
