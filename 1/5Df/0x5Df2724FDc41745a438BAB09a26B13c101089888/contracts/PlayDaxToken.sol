// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

/// @custom:security-contact daxtech@proton.me
contract PlayDax is ERC20, ERC20Burnable {
    constructor() ERC20("PlayDax", "PDAX") {
        _mint(msg.sender, 76658937 * 10 ** decimals());
    }

}