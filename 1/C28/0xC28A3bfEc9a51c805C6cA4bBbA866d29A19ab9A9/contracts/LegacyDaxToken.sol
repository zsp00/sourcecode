// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

/// @custom:security-contact daxtech@proton.me
contract LegacyDax is ERC20, ERC20Burnable {
    constructor() ERC20("LegacyDax", "LDAX") {
        _mint(msg.sender, 180252517* 10 ** decimals());
    }

}