// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts@4.8.0/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.8.0/access/Ownable.sol";

contract ConstellationChainToken is ERC20, Ownable {
    constructor() ERC20("Constellation Chain Token", "CCT") {
        _mint(msg.sender, 100000000000000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
