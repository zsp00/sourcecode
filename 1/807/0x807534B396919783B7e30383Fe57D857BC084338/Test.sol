// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Test is ERC20 {
    constructor() ERC20("Test", "TEST") {
        _mint(msg.sender, 1_000_000_000 * 10**18);
    }
}