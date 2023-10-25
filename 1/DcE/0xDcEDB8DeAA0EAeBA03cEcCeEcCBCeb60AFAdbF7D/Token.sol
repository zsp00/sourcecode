// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;
import "./ERC20.sol";

/**
    The best techno club?
    Yep, that's us.
**/

contract Bassiani is ERC20 {
    constructor() ERC20(unicode"Bassiani", unicode"BASSIANI") {
        _mint(msg.sender, 1_000_000_000 * 10 ** 18);
    }
}