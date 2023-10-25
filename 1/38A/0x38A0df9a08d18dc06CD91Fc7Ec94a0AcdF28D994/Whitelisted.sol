pragma solidity ^0.5.11;

import "./Ownable.sol";

contract Whitelisted {
    address private _whitelistadmin;
    address public pendingWhiteListAdmin;

    mapping (address => bool) private _whitelisted;

    modifier onlyWhitelistAdmin() {
        require(msg.sender == _whitelistadmin, "caller is not admin of whitelist");
        _;
    }

    modifier onlyPendingWhitelistAdmin() {
        require(msg.sender == pendingWhiteListAdmin);
        _;
    }

    event WhitelistAdminTransferred(address indexed previousAdmin, address indexed newAdmin);

    constructor () internal {
        _whitelistadmin = msg.sender;
        _whitelisted[msg.sender] = true;
    }

    function whitelistadmin() public view returns (address){
        return _whitelistadmin;
    }
    function addWhitelisted(address account) public onlyWhitelistAdmin {
        _whitelisted[account] = true;
    }

    function removeWhitelisted(address account) public onlyWhitelistAdmin {
        _whitelisted[account] = false;
    }

    function isWhitelisted(address account) public view returns (bool) {
        return _whitelisted[account];
    }

    function transferWhitelistAdmin(address newAdmin) public onlyWhitelistAdmin {
        pendingWhiteListAdmin = newAdmin;
    }

    function claimWhitelistAdmin() public onlyPendingWhitelistAdmin {
        emit WhitelistAdminTransferred(_whitelistadmin, pendingWhiteListAdmin);
        _whitelistadmin = pendingWhiteListAdmin;
        pendingWhiteListAdmin = address(0);
    }
}