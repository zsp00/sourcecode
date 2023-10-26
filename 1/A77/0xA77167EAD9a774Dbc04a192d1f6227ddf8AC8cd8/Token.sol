// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "./ERC20.sol";

contract Quailrun is ERC20 {
    constructor() ERC20("Quailrun", "QLR") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
}