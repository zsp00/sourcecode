pragma solidity ^0.5.11;

import "./Mintable.sol";

contract Pausable {
    bool private _paused;
    address private _pauser;
    address public pendingPauser;

    modifier onlyPauser() {
        require(msg.sender == _pauser, "caller is not a pauser");
        _;
    }

    modifier onlyPendingPauser() {
        require(msg.sender == pendingPauser);
        _;
    }

    event PauserTransferred(address indexed previousPauser, address indexed newPauser);


    constructor () internal {
        _paused = false;
        _pauser = msg.sender;
    }

    function paused() public view returns (bool) {
        return _paused;
    }

    function pauser() public view returns (address) {
        return _pauser;
    }

    function pauseTrigger() public onlyPauser {
        _paused = !_paused;
    }

    function transferPauser(address newPauser) public onlyPauser {
        pendingPauser = newPauser;
    }

    function claimPauser() public onlyPendingPauser {
        emit PauserTransferred(_pauser, pendingPauser);
        _pauser = pendingPauser;
        pendingPauser = address(0);
    }
}