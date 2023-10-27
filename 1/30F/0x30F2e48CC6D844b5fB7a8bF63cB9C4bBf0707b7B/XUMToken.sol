pragma solidity ^0.6.0;

import "./ERC20.sol";
import "./Ownable.sol";
import './ReentrancyGuard.sol';

contract XUMToken is ERC20, Ownable, ReentrancyGuard {
    
    constructor() public ERC20("XUM","XUM") {
        uint256 amount = 5000000000 * 10 ** 18;
        _mint(msg.sender, amount);
    }

}