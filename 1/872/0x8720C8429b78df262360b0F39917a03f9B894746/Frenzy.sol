{"Context.sol":{"content":"pragma solidity ^0.6.0;\r\n\r\n/*\r\n * @dev Provides information about the current execution context, including the\r\n * sender of the transaction and its data. While these are generally available\r\n * via msg.sender and msg.data, they should not be accessed in such a direct\r\n * manner, since when dealing with GSN meta-transactions the account sending and\r\n * paying for execution may not be the actual sender (as far as an application\r\n * is concerned).\r\n *\r\n * This contract is only required for intermediate, library-like contracts.\r\n */\r\ncontract Context {\r\n    // Empty internal constructor, to prevent people from mistakenly deploying\r\n    // an instance of this contract, which should be used via inheritance.\r\n    constructor () internal { }\r\n\r\n    function _msgSender() internal view virtual returns (address payable) {\r\n        return msg.sender;\r\n    }\r\n\r\n    function _msgData() internal view virtual returns (bytes memory) {\r\n        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\r\n        return msg.data;\r\n    }\r\n}"},"ERC20.sol":{"content":"pragma solidity ^0.6.0;\r\n\r\nimport \"./Context.sol\";\r\nimport \"./IERC20.sol\";\r\nimport \"./SafeMath.sol\";\r\n\r\n/**\r\n * @dev Implementation of the {IERC20} interface.\r\n *\r\n * This implementation is agnostic to the way tokens are created. This means\r\n * that a supply mechanism has to be added in a derived contract using {_mint}.\r\n * For a generic mechanism see {ERC20Mintable}.\r\n *\r\n * TIP: For a detailed writeup see our guide\r\n * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How\r\n * to implement supply mechanisms].\r\n *\r\n * We have followed general OpenZeppelin guidelines: functions revert instead\r\n * of returning `false` on failure. This behavior is nonetheless conventional\r\n * and does not conflict with the expectations of ERC20 applications.\r\n *\r\n * Additionally, an {Approval} event is emitted on calls to {transferFrom}.\r\n * This allows applications to reconstruct the allowance for all accounts just\r\n * by listening to said events. Other implementations of the EIP may not emit\r\n * these events, as it isn\u0027t required by the specification.\r\n *\r\n * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}\r\n * functions have been added to mitigate the well-known issues around setting\r\n * allowances. See {IERC20-approve}.\r\n */\r\ncontract ERC20 is Context, IERC20 {\r\n    using SafeMath for uint256;\r\n\r\n    mapping (address =\u003e uint256) internal _balances;\r\n\r\n    mapping (address =\u003e mapping (address =\u003e uint256)) private _allowances;\r\n\r\n    uint256 private _totalSupply;\r\n\r\n    /**\r\n     * @dev See {IERC20-totalSupply}.\r\n     */\r\n    function totalSupply() public view override returns (uint256) {\r\n        return _totalSupply;\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-balanceOf}.\r\n     */\r\n    function balanceOf(address account) public view override returns (uint256) {\r\n        return _balances[account];\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-transfer}.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `recipient` cannot be the zero address.\r\n     * - the caller must have a balance of at least `amount`.\r\n     */\r\n    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {\r\n        _transfer(_msgSender(), recipient, amount);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-allowance}.\r\n     */\r\n    function allowance(address owner, address spender) public view virtual override returns (uint256) {\r\n        return _allowances[owner][spender];\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-approve}.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `spender` cannot be the zero address.\r\n     */\r\n    function approve(address spender, uint256 amount) public virtual override returns (bool) {\r\n        _approve(_msgSender(), spender, amount);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-transferFrom}.\r\n     *\r\n     * Emits an {Approval} event indicating the updated allowance. This is not\r\n     * required by the EIP. See the note at the beginning of {ERC20};\r\n     *\r\n     * Requirements:\r\n     * - `sender` and `recipient` cannot be the zero address.\r\n     * - `sender` must have a balance of at least `amount`.\r\n     * - the caller must have allowance for `sender`\u0027s tokens of at least\r\n     * `amount`.\r\n     */\r\n    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {\r\n        _transfer(sender, recipient, amount);\r\n        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, \"ERC20: transfer amount exceeds allowance\"));\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Atomically increases the allowance granted to `spender` by the caller.\r\n     *\r\n     * This is an alternative to {approve} that can be used as a mitigation for\r\n     * problems described in {IERC20-approve}.\r\n     *\r\n     * Emits an {Approval} event indicating the updated allowance.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `spender` cannot be the zero address.\r\n     */\r\n    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {\r\n        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Atomically decreases the allowance granted to `spender` by the caller.\r\n     *\r\n     * This is an alternative to {approve} that can be used as a mitigation for\r\n     * problems described in {IERC20-approve}.\r\n     *\r\n     * Emits an {Approval} event indicating the updated allowance.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `spender` cannot be the zero address.\r\n     * - `spender` must have allowance for the caller of at least\r\n     * `subtractedValue`.\r\n     */\r\n    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {\r\n        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, \"ERC20: decreased allowance below zero\"));\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Moves tokens `amount` from `sender` to `recipient`.\r\n     *\r\n     * This is internal function is equivalent to {transfer}, and can be used to\r\n     * e.g. implement automatic token fees, slashing mechanisms, etc.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `sender` cannot be the zero address.\r\n     * - `recipient` cannot be the zero address.\r\n     * - `sender` must have a balance of at least `amount`.\r\n     */\r\n    function _transfer(address sender, address recipient, uint256 amount) internal virtual {\r\n        require(sender != address(0), \"ERC20: transfer from the zero address\");\r\n        require(recipient != address(0), \"ERC20: transfer to the zero address\");\r\n\r\n        _beforeTokenTransfer(sender, recipient, amount);\r\n\r\n        _balances[sender] = _balances[sender].sub(amount, \"ERC20: transfer amount exceeds balance\");\r\n        _balances[recipient] = _balances[recipient].add(amount);\r\n        emit Transfer(sender, recipient, amount);\r\n    }\r\n\r\n    /** @dev Creates `amount` tokens and assigns them to `account`, increasing\r\n     * the total supply.\r\n     *\r\n     * Emits a {Transfer} event with `from` set to the zero address.\r\n     *\r\n     * Requirements\r\n     *\r\n     * - `to` cannot be the zero address.\r\n     */\r\n    function _mint(address account, uint256 amount) internal virtual {\r\n        require(account != address(0), \"ERC20: mint to the zero address\");\r\n\r\n        _beforeTokenTransfer(address(0), account, amount);\r\n\r\n        _totalSupply = _totalSupply.add(amount);\r\n        _balances[account] = _balances[account].add(amount);\r\n        emit Transfer(address(0), account, amount);\r\n    }\r\n\r\n    /**\r\n     * @dev Destroys `amount` tokens from `account`, reducing the\r\n     * total supply.\r\n     *\r\n     * Emits a {Transfer} event with `to` set to the zero address.\r\n     *\r\n     * Requirements\r\n     *\r\n     * - `account` cannot be the zero address.\r\n     * - `account` must have at least `amount` tokens.\r\n     */\r\n    function _burn(address account, uint256 amount) internal virtual {\r\n        require(account != address(0), \"ERC20: burn from the zero address\");\r\n\r\n        _beforeTokenTransfer(account, address(0), amount);\r\n\r\n        _balances[account] = _balances[account].sub(amount, \"ERC20: burn amount exceeds balance\");\r\n        _totalSupply = _totalSupply.sub(amount);\r\n        emit Transfer(account, address(0), amount);\r\n    }\r\n\r\n    /**\r\n     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.\r\n     *\r\n     * This is internal function is equivalent to `approve`, and can be used to\r\n     * e.g. set automatic allowances for certain subsystems, etc.\r\n     *\r\n     * Emits an {Approval} event.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `owner` cannot be the zero address.\r\n     * - `spender` cannot be the zero address.\r\n     */\r\n    function _approve(address owner, address spender, uint256 amount) internal virtual {\r\n        require(owner != address(0), \"ERC20: approve from the zero address\");\r\n        require(spender != address(0), \"ERC20: approve to the zero address\");\r\n\r\n        _allowances[owner][spender] = amount;\r\n        emit Approval(owner, spender, amount);\r\n    }\r\n\r\n    /**\r\n     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted\r\n     * from the caller\u0027s allowance.\r\n     *\r\n     * See {_burn} and {_approve}.\r\n     */\r\n    function _burnFrom(address account, uint256 amount) internal virtual {\r\n        _burn(account, amount);\r\n        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, \"ERC20: burn amount exceeds allowance\"));\r\n    }\r\n\r\n    /**\r\n     * @dev Hook that is called before any transfer of tokens. This includes\r\n     * minting and burning.\r\n     *\r\n     * Calling conditions:\r\n     *\r\n     * - when `from` and `to` are both non-zero, `amount` of `from`\u0027s tokens\r\n     * will be to transferred to `to`.\r\n     * - when `from` is zero, `amount` tokens will be minted for `to`.\r\n     * - when `to` is zero, `amount` of `from`\u0027s tokens will be burned.\r\n     * - `from` and `to` are never both zero.\r\n     *\r\n     * To learn more about hooks, head to xref:ROOT:using-hooks.adoc[Using Hooks].\r\n     */\r\n    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }\r\n}"},"ERC20Detailed.sol":{"content":"pragma solidity ^0.6.0;\r\n\r\nimport \"./IERC20.sol\";\r\n\r\n/**\r\n * @dev Optional functions from the ERC20 standard.\r\n */\r\nabstract contract ERC20Detailed is IERC20 {\r\n    string private _name;\r\n    string private _symbol;\r\n    uint8 private _decimals;\r\n\r\n    /**\r\n     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of\r\n     * these values are immutable: they can only be set once during\r\n     * construction.\r\n     */\r\n    constructor (string memory name, string memory symbol, uint8 decimals) public {\r\n        _name = name;\r\n        _symbol = symbol;\r\n        _decimals = decimals;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the name of the token.\r\n     */\r\n    function name() public view returns (string memory) {\r\n        return _name;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the symbol of the token, usually a shorter version of the\r\n     * name.\r\n     */\r\n    function symbol() public view returns (string memory) {\r\n        return _symbol;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the number of decimals used to get its user representation.\r\n     * For example, if `decimals` equals `2`, a balance of `505` tokens should\r\n     * be displayed to a user as `5,05` (`505 / 10 ** 2`).\r\n     *\r\n     * Tokens usually opt for a value of 18, imitating the relationship between\r\n     * Ether and Wei.\r\n     *\r\n     * NOTE: This information is only used for _display_ purposes: it in\r\n     * no way affects any of the arithmetic of the contract, including\r\n     * {IERC20-balanceOf} and {IERC20-transfer}.\r\n     */\r\n    function decimals() public view returns (uint8) {\r\n        return _decimals;\r\n    }\r\n}"},"ERC20Pausable.sol":{"content":"pragma solidity ^0.6.0;\r\n\r\nimport \"./ERC20.sol\";\r\nimport \"./Pausable.sol\";\r\n\r\n/**\r\n * @title Pausable token\r\n * @dev ERC20 with pausable transfers and allowances.\r\n *\r\n * Useful if you want to stop trades until the end of a crowdsale, or have\r\n * an emergency switch for freezing all token transfers in the event of a large\r\n * bug.\r\n */\r\ncontract ERC20Pausable is ERC20, Pausable {\r\n    /**\r\n     * @dev See {ERC20-_beforeTokenTransfer}.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - the contract must not be paused.\r\n     */\r\n    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {\r\n        super._beforeTokenTransfer(from, to, amount);\r\n\r\n        require(!paused(), \"ERC20Pausable: token transfer while paused\");\r\n    }\r\n}"},"Frenzy.sol":{"content":"pragma solidity ^0.6.0;\r\n\r\nimport \"./ERC20Detailed.sol\";\r\nimport \"./ERC20Pausable.sol\";\r\nimport \"./Ownable.sol\";\r\n\r\ncontract Frenzy is ERC20Detailed, ERC20Pausable, Ownable {\r\n    string private _name = \"Frenzy\";\r\n    string private _symbol = \"FZY\";\r\n    uint8 private _decimals = 8;\r\n    uint256 private _totalSupply = uint256(10000000000).mul(10 ** uint256(_decimals));\r\n    address private _account = msg.sender;\r\n\r\n    mapping (address =\u003e uint256) public _lockedBalances;\r\n\r\n    event LockUpdate(address indexed account, uint256 value);\r\n\r\n    constructor () ERC20Detailed(_name, _symbol, _decimals) Ownable() public {\r\n        _mint(_account, _totalSupply);\r\n    }\r\n    \r\n    function balancesOf(address[] memory accounts) public view returns (uint256[] memory) {\r\n        uint256[] memory _balance = new uint256[](accounts.length);\r\n        for (uint256 i = 0; i \u003c accounts.length; i++) {\r\n            _balance[i] = _balances[accounts[i]];\r\n        }\r\n        return _balance;\r\n    }\r\n    \r\n    /**\r\n     * @dev Input format:\r\n     * - [] (square brackets) for both `recipient` and `amount`.\r\n     * - , (comma separated) with NO spacing for both `recipient` and `amount`.\r\n     * - \"\" (double quotes) for `recipient`.\r\n     * - NO double quotes for `amount`.\r\n     *\r\n     * Example:\r\n     * [\"recipient1\",\"recipients\"]\r\n     * [amount1,amount2]\r\n     */\r\n    function transfers(address[] memory recipients, uint256[] memory amounts) public returns (bool) {\r\n        uint256 _total;\r\n        address _sender = _msgSender();\r\n        require(_sender != address(0), \"ERC20: transfer from the zero address\");\r\n        for (uint256 i = 0; i \u003c recipients.length; i++) {\r\n            require(recipients[i] != address(0), \"ERC20: transfer to the zero address\");\r\n            require(amounts[i] \u003e 0, \"Frenzy: negative transfer amount\");\r\n            \r\n            _total = _total.add(amounts[i]);\r\n            \r\n            _beforeTokenTransfer(_sender, recipients[i], amounts[i]);\r\n        }\r\n        \r\n        /**\r\n         * @dev Additional {Frenzy} requirement:\r\n         * - `sender` must have a balance of at least `amount` + locked balance.\r\n         */\r\n        _balances[_sender].sub(_total, \"ERC20: transfer amount exceeds balance\")\r\n        .sub(_lockedBalances[_sender], \"Frenzy: insufficient unlocked balance\");\r\n        \r\n        _balances[_sender] = _balances[_sender].sub(_total);\r\n        for (uint256 i = 0; i \u003c recipients.length; i++) {\r\n            _balances[recipients[i]] = _balances[recipients[i]].add(amounts[i]);\r\n            emit Transfer(_sender, recipients[i], amounts[i]);\r\n        }\r\n        \r\n        return true;\r\n    }\r\n\r\n    function _transfer(address sender, address recipient, uint256 amount) internal override {\r\n        require(sender != address(0), \"ERC20: transfer from the zero address\");\r\n        require(recipient != address(0), \"ERC20: transfer to the zero address\");\r\n\r\n        _beforeTokenTransfer(sender, recipient, amount);\r\n\r\n        /**\r\n         * @dev Additional {Frenzy} requirement:\r\n         * - `sender` must have a balance of at least `amount` + locked balance.\r\n         */\r\n        _balances[sender].sub(amount, \"ERC20: transfer amount exceeds balance\")\r\n        .sub(_lockedBalances[sender], \"Frenzy: insufficient unlocked balance\");\r\n\r\n        _balances[sender] = _balances[sender].sub(amount);\r\n        _balances[recipient] = _balances[recipient].add(amount);\r\n        emit Transfer(sender, recipient, amount);\r\n    }\r\n    \r\n    function pause() onlyOwner public {\r\n        _pause();\r\n    }\r\n    \r\n    function unpause() onlyOwner public {\r\n        _unpause();\r\n    }\r\n\r\n    function lockedBalanceOf(address account) public view returns (uint256 lockedBalance, uint256 unlockedBalance) {\r\n        return (_lockedBalances[account], _balances[account].sub(_lockedBalances[account]));\r\n    }\r\n    \r\n    function lockedBalancesOf(address[] memory accounts) public view returns (uint256[] memory lockedBalances, uint256[] memory unlockedBalances) {\r\n        uint256[] memory _lockedBalance = new uint256[](accounts.length);\r\n        uint256[] memory _unlockedBalance = new uint256[](accounts.length);\r\n        for (uint256 i = 0; i \u003c accounts.length; i++) {\r\n            _lockedBalance[i] = _lockedBalances[accounts[i]];\r\n            _unlockedBalance[i] = _balances[accounts[i]].sub(_lockedBalances[accounts[i]]);\r\n        }\r\n        return (_lockedBalance, _unlockedBalance);\r\n    }\r\n\r\n    function lockUpdate(address account, uint256 amount) onlyOwner public returns (bool) {\r\n        _lockUpdate(account, amount);\r\n        return true;\r\n    }\r\n    \r\n    function lockUpdates(address[] memory accounts, uint256[] memory amounts) onlyOwner public returns (bool) {\r\n        for (uint256 i = 0; i \u003c accounts.length; i++) {\r\n            _lockUpdate(accounts[i], amounts[i]);\r\n        }\r\n        return true;\r\n    }\r\n\r\n    function _lockUpdate(address account, uint256 amount) private returns (bool) {\r\n        require(amount \u003e= 0, \"Frenzy: negative locked balance\");\r\n        _lockedBalances[account] = amount;\r\n        emit LockUpdate(account, amount);\r\n    }\r\n}"},"IERC20.sol":{"content":"pragma solidity ^0.6.0;\r\n\r\n/**\r\n * @dev Interface of the ERC20 standard as defined in the EIP. Does not include\r\n * the optional functions; to access them see {ERC20Detailed}.\r\n */\r\ninterface IERC20 {\r\n    /**\r\n     * @dev Returns the amount of tokens in existence.\r\n     */\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens owned by `account`.\r\n     */\r\n    function balanceOf(address account) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Moves `amount` tokens from the caller\u0027s account to `recipient`.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Returns the remaining number of tokens that `spender` will be\r\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\r\n     * zero by default.\r\n     *\r\n     * This value changes when {approve} or {transferFrom} are called.\r\n     */\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Sets `amount` as the allowance of `spender` over the caller\u0027s tokens.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\r\n     * that someone may use both the old and the new allowance by unfortunate\r\n     * transaction ordering. One possible solution to mitigate this race\r\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\r\n     * desired value afterwards:\r\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n     *\r\n     * Emits an {Approval} event.\r\n     */\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\r\n     * allowance mechanism. `amount` is then deducted from the caller\u0027s\r\n     * allowance.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\r\n     * another (`to`).\r\n     *\r\n     * Note that `value` may be zero.\r\n     */\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    /**\r\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\r\n     * a call to {approve}. `value` is the new allowance.\r\n     */\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}"},"Ownable.sol":{"content":"pragma solidity ^0.6.0;\r\n\r\nimport \"./Context.sol\";\r\n/**\r\n * @dev Contract module which provides a basic access control mechanism, where\r\n * there is an account (an owner) that can be granted exclusive access to\r\n * specific functions.\r\n *\r\n * This module is used through inheritance. It will make available the modifier\r\n * `onlyOwner`, which can be applied to your functions to restrict their use to\r\n * the owner.\r\n */\r\ncontract Ownable is Context {\r\n    address private _owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n     * @dev Initializes the contract setting the deployer as the initial owner.\r\n     */\r\n    constructor () internal {\r\n        address msgSender = _msgSender();\r\n        _owner = msgSender;\r\n        emit OwnershipTransferred(address(0), msgSender);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the address of the current owner.\r\n     */\r\n    function owner() public view returns (address) {\r\n        return _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(isOwner(), \"Ownable: caller is not the owner\");\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns true if the caller is the current owner.\r\n     */\r\n    function isOwner() public view returns (bool) {\r\n        return _msgSender() == _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Leaves the contract without owner. It will not be possible to call\r\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\r\n     *\r\n     * NOTE: Renouncing ownership will leave the contract without an owner,\r\n     * thereby removing any functionality that is only available to the owner.\r\n     */\r\n    function renounceOwnership() public virtual onlyOwner {\r\n        emit OwnershipTransferred(_owner, address(0));\r\n        _owner = address(0);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\r\n     * Can only be called by the current owner.\r\n     */\r\n    function transferOwnership(address newOwner) public virtual onlyOwner {\r\n        _transferOwnership(newOwner);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\r\n     */\r\n    function _transferOwnership(address newOwner) internal virtual {\r\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\r\n        emit OwnershipTransferred(_owner, newOwner);\r\n        _owner = newOwner;\r\n    }\r\n}"},"Pausable.sol":{"content":"pragma solidity ^0.6.0;\r\n\r\nimport \"./Context.sol\";\r\n\r\n/**\r\n * @dev Contract module which allows children to implement an emergency stop\r\n * mechanism that can be triggered by an authorized account.\r\n *\r\n * This module is used through inheritance. It will make available the\r\n * modifiers `whenNotPaused` and `whenPaused`, which can be applied to\r\n * the functions of your contract. Note that they will not be pausable by\r\n * simply including this module, only once the modifiers are put in place.\r\n */\r\ncontract Pausable is Context {\r\n    /**\r\n     * @dev Emitted when the pause is triggered by a pauser (`account`).\r\n     */\r\n    event Paused(address account);\r\n\r\n    /**\r\n     * @dev Emitted when the pause is lifted by a pauser (`account`).\r\n     */\r\n    event Unpaused(address account);\r\n\r\n    bool private _paused;\r\n\r\n    /**\r\n     * @dev Initializes the contract in unpaused state. Assigns the Pauser role\r\n     * to the deployer.\r\n     */\r\n    constructor () internal {\r\n        _paused = false;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns true if the contract is paused, and false otherwise.\r\n     */\r\n    function paused() public view returns (bool) {\r\n        return _paused;\r\n    }\r\n\r\n    /**\r\n     * @dev Modifier to make a function callable only when the contract is not paused.\r\n     */\r\n    modifier whenNotPaused() {\r\n        require(!_paused, \"Pausable: paused\");\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Modifier to make a function callable only when the contract is paused.\r\n     */\r\n    modifier whenPaused() {\r\n        require(_paused, \"Pausable: not paused\");\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Called by a pauser to pause, triggers stopped state.\r\n     */\r\n    function _pause() internal virtual whenNotPaused {\r\n        _paused = true;\r\n        emit Paused(_msgSender());\r\n    }\r\n\r\n    /**\r\n     * @dev Called by a pauser to unpause, returns to normal state.\r\n     */\r\n    function _unpause() internal virtual whenPaused {\r\n        _paused = false;\r\n        emit Unpaused(_msgSender());\r\n    }\r\n}"},"SafeMath.sol":{"content":"pragma solidity ^0.6.0;\r\n\r\n/**\r\n * @dev Wrappers over Solidity\u0027s arithmetic operations with added overflow\r\n * checks.\r\n *\r\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\r\n * in bugs, because programmers usually assume that an overflow raises an\r\n * error, which is the standard behavior in high level programming languages.\r\n * `SafeMath` restores this intuition by reverting the transaction when an\r\n * operation overflows.\r\n *\r\n * Using this library instead of the unchecked operations eliminates an entire\r\n * class of bugs, so it\u0027s recommended to use it always.\r\n */\r\nlibrary SafeMath {\r\n    /**\r\n     * @dev Returns the addition of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s `+` operator.\r\n     *\r\n     * Requirements:\r\n     * - Addition cannot overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a + b;\r\n        require(c \u003e= a, \"SafeMath: addition overflow\");\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s `-` operator.\r\n     *\r\n     * Requirements:\r\n     * - Subtraction cannot overflow.\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return sub(a, b, \"SafeMath: subtraction overflow\");\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s `-` operator.\r\n     *\r\n     * Requirements:\r\n     * - Subtraction cannot overflow.\r\n     *\r\n     * _Available since v2.4.0._\r\n     */\r\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b \u003c= a, errorMessage);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the multiplication of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s `*` operator.\r\n     *\r\n     * Requirements:\r\n     * - Multiplication cannot overflow.\r\n     */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \"SafeMath: multiplication overflow\");\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\r\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return div(a, b, \"SafeMath: division by zero\");\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\r\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     *\r\n     * _Available since v2.4.0._\r\n     */\r\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        // Solidity only automatically asserts when dividing by 0\r\n        require(b \u003e 0, errorMessage);\r\n        uint256 c = a / b;\r\n        // assert(a == b * c + a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return mod(a, b, \"SafeMath: modulo by zero\");\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts with custom message when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     *\r\n     * _Available since v2.4.0._\r\n     */\r\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b != 0, errorMessage);\r\n        return a % b;\r\n    }\r\n}"}}