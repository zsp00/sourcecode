pragma solidity ^0.5.11;

import "./Pausable.sol";

contract TokenRecipient {
    function receiveApproval(address _from, uint256 _value, address _token, bytes memory _extraData) public;
}