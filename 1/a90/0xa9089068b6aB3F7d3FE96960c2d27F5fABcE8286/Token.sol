// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "./ERC20.sol";

contract Railway is ERC20 {
    constructor() ERC20("Railway", "RLW") {
        _mint(msg.sender, 10000000 * 10 ** decimals());
    }
}