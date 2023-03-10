// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts@4.8.2/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.8.2/token/ERC20/extensions/ERC20Burnable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol";

contract SimPLtoken is ERC20, ERC20Burnable, ReentrancyGuard {
    constructor(uint256 initialSupply) ERC20("SimPL token", "SimPL") {
        _mint(msg.sender, initialSupply);
    }
    
    function transfer(address recipient, uint256 amount) public virtual override nonReentrant returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    
    function balanceOf(address account) public view override returns (uint256) {
        return super.balanceOf(account);
    }
}
