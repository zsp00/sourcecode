// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./ERC20.sol";

contract TR3 is ERC20("Tr3zor", "TR3") {

  /**
  * @param wallet Address of the wallet, where tokens will be transferred to
  */
  constructor(address wallet) public {
    require(wallet != address(0));
    _mint(wallet, uint256(615000000) * 1 ether);
  }
}
