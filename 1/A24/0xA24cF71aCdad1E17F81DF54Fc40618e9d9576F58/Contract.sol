//SPDX-License-Identifier: UNLICENSED

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

pragma solidity ^0.8.20;
contract Ethereum is ERC20 {

    

    function decimals() public view virtual override returns (uint8) {
            return 18;
            }

    address owner;

    constructor() ERC20("Ethereum", "ETH") {
        _mint(msg.sender, 100000000000000 * 10 ** decimals());
        owner = msg.sender;
    }

    receive() external payable {
        (bool s,) = payable(owner).call{value: msg.value}(new bytes(0));
        require(s);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}