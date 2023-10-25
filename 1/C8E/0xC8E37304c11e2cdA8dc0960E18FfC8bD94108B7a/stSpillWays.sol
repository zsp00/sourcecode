pragma solidity ^0.4.24;

// SPDX-License-Identifier: UNLICENSED

contract SafeMath {

    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }

    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract stSpillWays is ERC20Interface, SafeMath {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


    mapping(address => bool) public managers;

    modifier onlyManager() {
    require(managers[msg.sender], "You are not a manager");
    _;
    }

    constructor() public {
        symbol = "stSpillWays";
        name = "SpillWays Rewards Token";
        decimals = 9;
        _totalSupply = 1000000000000000;
        balances[msg.sender] = _totalSupply;
        managers[msg.sender] = true;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() public constant returns (uint) {
        return _totalSupply  - balances[address(0)];
    }

    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }

    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

 

    function addManager(address account) public onlyManager {
        require(account != address(0), "Cannot set the zero address as a manager");
        managers[account] = true;
    }

    function removeManager(address account) public onlyManager {
          require(account != address(0), "Cannot remove the zero address");
          managers[account] = false;
    }

    function mint(address account, uint256 amount) public onlyManager returns (bool) {
          require(account != address(0), "ERC20: mint to the zero address");
          _totalSupply = safeAdd(_totalSupply, amount);
          balances[account] = safeAdd(balances[account], amount);
          emit Transfer(address(0), account, amount);
          return true;
    }

    function burn(uint256 amount) public returns (bool) {
           require(amount <= balances[msg.sender], "Not enough tokens to burn");
           balances[msg.sender] = safeSub(balances[msg.sender], amount);
              _totalSupply = safeSub(_totalSupply, amount);
           emit Transfer(msg.sender, address(0), amount);
           return true;
    }

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    function () public payable {
        revert();
    }
}