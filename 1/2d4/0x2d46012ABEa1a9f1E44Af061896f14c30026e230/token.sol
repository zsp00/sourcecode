// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract Tether is ERC20, Ownable {
    constructor() ERC20("Tether (USDT)", "USDT"){
        _mint(msg.sender, 5000000 * 10 ** decimals());
    }
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
    function decimals() override public pure returns (uint8) {
        return 6;
    }
}