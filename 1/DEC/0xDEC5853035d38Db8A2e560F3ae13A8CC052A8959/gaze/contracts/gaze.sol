// SPDX-License-Identifier: MIT

// Deployed with the Atlas IDE
// https://app.atlaszk.com

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Gaze is ERC20, Ownable {
    uint256 public constant MAX_SUPPLY = 50 * (10 ** 18);
    uint256 public constant TOKEN_PRICE = 0.1 ether;

    constructor() ERC20("Gaze", "GAZE") {
        _mint(msg.sender, MAX_SUPPLY);
    }

    function buy() public payable {
        uint256 contractBalance = balanceOf(address(this));
        require(contractBalance > 0, "No more tokens left to buy");

        uint256 tokensToBuy = msg.value / TOKEN_PRICE;
        require(tokensToBuy <= contractBalance, "Not enough tokens left");

        uint256 cost = tokensToBuy * TOKEN_PRICE;
        uint256 refund = msg.value - cost;

        if(refund > 0) {
            payable(msg.sender).transfer(refund);
        }

        _burn(address(this), tokensToBuy);
        _transfer(address(this), msg.sender, tokensToBuy);
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}