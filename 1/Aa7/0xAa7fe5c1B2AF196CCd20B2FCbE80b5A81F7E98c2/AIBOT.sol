// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract ERC20 is Context, IERC20 {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

contract AIBOT is Ownable, ERC20 {

    address public constant DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    address public constant TEAM_ADDRESS = 0xD9a12bFbc2802E3Da40EdEad99E391c5BBf26BAF;
    address public constant HOLDER_ADDRESS = 0x329426D2E3ebf145EC80144D98EC4346b4A593B4;
    address public constant TOKEN_ADDRESS = 0x11ccf09AAeb5f59311e010af5347c616A3c63c03;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    IUniswapV2Router02 public immutable uniswapV2Router;
    IUniswapV2Factory public immutable uniswapV2Factory;

    bool swapping;
    bool public startTrading;
    address public teamReward;
    address public holderReward;
    address public tokenReward;
    address public burnAddress;
    uint256 public buyFeeRate;
    uint256 public sellFeeRate;
    uint256 public totalFeeAmount;
    uint256 public swapAmount;
    uint256 public holderShare;
    uint256 public burnShare;
    uint256 public teamShare;
    uint256 public tokenShare;
    uint256 public burnLimit;
    mapping (address => mapping(address => uint256)) public balanceFromPool;
    mapping (address => bool) public uniswapPool;
    mapping (address => bool) public dutyFree;
    mapping (address => uint256) public lastTradingBlock;

    event SwapAmountSet(address indexed owner, uint256 indexed amount);
    event TeamSet(address indexed owner, address indexed account);
    event BurnAddressSet(address indexed owner, address indexed account);
    event ShareSet(address indexed owner, uint256 burnShare, uint256 holderShare,uint256 teamShare,uint256 tokenShare);
    event HolderRewardSet(address indexed owner, address indexed account);
    event TokenRewardSet(address indexed owner, address indexed account);
    event LimitSet(address indexed owner, bool indexed limited, uint256 indexed amount);
    event PoolSet(address indexed owner, address indexed account, bool indexed value);
    event DutyFreeSet(address indexed owner, address indexed account, bool indexed value);
    event FeeRateSet(address indexed owner, uint256 indexed buyFeeRate, uint256 indexed sellFeeRate);
    event BurnLimitSet(address indexed owner, uint256 burnLimit);

    constructor(uint256 _totalSupply) ERC20("AIBOT", "AIBOT") {
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Factory = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
       
        swapping = false;

        swapAmount = (_totalSupply * 1) / 10000; 

        holderShare = 0.4 ether;
        burnShare = 0.2 ether;
        teamShare = 0.3 ether;
        tokenShare = 0.1 ether;

        burnLimit = _totalSupply / 10000;

        buyFeeRate = 0.05 ether;
        sellFeeRate = 0.05 ether;
        
        teamReward = TEAM_ADDRESS;
        tokenReward = TOKEN_ADDRESS;
        holderReward = HOLDER_ADDRESS;
        burnAddress = DEAD_ADDRESS;

        dutyFree[msg.sender] = true;
        dutyFree[address(this)] = true;

        _mint(msg.sender, _totalSupply);

        address pair = uniswapV2Factory.createPair(address(this), WETH);
        setPool(pair);
    }

    fallback() external payable {}

    receive() external payable {}

    function setStartTrading() external onlyOwner {
        startTrading = true;
    }

    function withdrawToken(address token, address to) external onlyOwner {
        require(token != address(0), "token address cannot be zero address");
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(to, balance);
    }

    function withdrawEth(address to) external onlyOwner {
        (bool success, ) = to.call{value: address(this).balance}(new bytes(0));
        require(success, "eth transfer failed");
    }

    function setPool(address account) public  onlyOwner {
        uniswapPool[account] = !uniswapPool[account];
        emit PoolSet(msg.sender, account, uniswapPool[account]);
    }

    function setTeam(address account) external onlyOwner {
        teamReward = account;
        emit TeamSet(msg.sender, teamReward);
    }

    function setHolderReward(address account) external onlyOwner {
        holderReward = account;
        emit HolderRewardSet(msg.sender, holderReward);
    }

    function setTokenReward(address account) external onlyOwner {
        tokenReward = account;
        emit TokenRewardSet(msg.sender, tokenReward);
    }

    function setBurnAddress(address account) external onlyOwner {
        burnAddress = account;
        emit BurnAddressSet(msg.sender, burnAddress);
    }

    function setDutyFree(address account) public onlyOwner {
        dutyFree[account] = !dutyFree[account];
        emit DutyFreeSet(msg.sender, account, dutyFree[account]);
    }

    function setFeeRate(uint256 _buyFeeRate, uint256 _sellFeeRate) external onlyOwner {
        buyFeeRate = _buyFeeRate;
        sellFeeRate = _sellFeeRate;
        emit FeeRateSet(msg.sender, _buyFeeRate, _sellFeeRate);
    }

    function setBurnLimit(uint256 _burnLimit) external onlyOwner {
        burnLimit = _burnLimit;
        emit BurnLimitSet(msg.sender, _burnLimit);
    }

    function setSwapAmount(uint256 _swapAmount) external onlyOwner {
        swapAmount = _swapAmount;
        emit SwapAmountSet(msg.sender, _swapAmount);
    }

    function setShare(uint256 _burnShare, uint256 _holderShare, uint256 _teamShare, uint256 _tokenShare) external onlyOwner {
        uint256 totalShare = _burnShare + _holderShare + _teamShare + _tokenShare;
        require(totalShare == 1 ether, "forbid");
        burnShare = _burnShare;
        holderShare = _holderShare;
        teamShare = _teamShare;
        tokenShare = _tokenShare;
        emit ShareSet(msg.sender, burnShare, holderShare, teamShare, tokenShare);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {

        if (!startTrading) {
            require(from == owner() || to == owner(), "trading is not started");
            return;
        }

        if (uniswapPool[from]) {
            balanceFromPool[to][from] += amount;
        }
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        if (!swapping && !uniswapPool[from]) {
            swapping = true;
            _swapBack();
            swapping = false;
        }

        uint256 feeRate = 0;
        if (uniswapPool[from]) {
            if (!dutyFree[to]) {
                feeRate = buyFeeRate;
            }
        } else if (uniswapPool[to]) {
            if (!dutyFree[from]) {
                feeRate = sellFeeRate;
            }
        }

        if (feeRate > 0 && amount > 0) {
            uint256 fee = amount * feeRate / 1 ether;
            totalFeeAmount += fee;
            super._transfer(from, address(this), fee);
            amount -= fee;
        }

        super._transfer(from, to, amount);
    }

    function _swapBack() internal {
        if (totalFeeAmount <= swapAmount) {
            return;
        }

        bool success;

        uint256 amountToHolder = totalFeeAmount * holderShare / 1 ether;
        uint256 amountToToken = totalFeeAmount * tokenShare / 1 ether;
        uint256 amountToBurn = totalFeeAmount * burnShare / 1 ether;
        uint256 amountToTeam = totalFeeAmount * teamShare / 1 ether;

        uint256 amountToSwap = amountToTeam + amountToHolder + amountToToken;

        if(totalSupply() - IERC20(address(this)).balanceOf(burnAddress) <= burnLimit){
            amountToSwap += amountToBurn;
        }

        uint256 initialETHBalance = address(this).balance;

        _swapTokensForEth(amountToSwap);

        uint256 totalShare = teamShare + holderShare + tokenShare;

        uint256 teamETHBalance = (address(this).balance - initialETHBalance) * teamShare / totalShare ;
        uint256 holderETHBalance = (address(this).balance - initialETHBalance) * holderShare / totalShare;
        uint256 tokenETHBalance = (address(this).balance - initialETHBalance) * tokenShare / totalShare;

        (success, ) = teamReward.call{value: teamETHBalance}(new bytes(0));
        require(success, "eth transfer failed");

        (success, ) = holderReward.call{value: holderETHBalance}(new bytes(0));
        require(success, "eth transfer failed");

        (success, ) = tokenReward.call{value: tokenETHBalance}(new bytes(0));
        require(success, "eth transfer failed");

        if(totalSupply() - IERC20(address(this)).balanceOf(burnAddress) > burnLimit){
            if(totalSupply() - IERC20(address(this)).balanceOf(burnAddress) - amountToBurn < burnLimit){
                IERC20(address(this)).transfer(burnAddress, totalSupply() - IERC20(address(this)).balanceOf(burnAddress) - burnLimit);
            }else {
                IERC20(address(this)).transfer(burnAddress, amountToBurn);
            }
        }
        totalFeeAmount = 0;
    }

    function _swapTokensForEth(uint256 amount) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        if (allowance(address(this), address(uniswapV2Router)) < amount) {
            _approve(address(this), address(uniswapV2Router), type(uint256).max);
        }

        uniswapV2Router.swapExactTokensForETH(amount, 0, path, address(this), block.timestamp);
    }

    function burn(uint256 value) external {
        _burn(msg.sender, value);
    }
}