// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts@5.0.0/token/ERC20/ERC20.sol";

contract X is ERC20 {
    constructor() ERC20("X", "X") {
        _mint(msg.sender, 21 * 10 ** 18);
    }
}