// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20UniswapV2InternalSwaps} from "./ERC20UniswapV2InternalSwaps.sol";

contract Pepeland is ERC20, Ownable, ERC20UniswapV2InternalSwaps {
    /** @notice Minimum threshold in ETH to trigger #swapTokensAndAddLiquidity. */
    uint256 public constant SWAP_THRESHOLD_ETH_MIN = 0.005 ether;
    /** @notice Maximum threshold in ETH to trigger #swapTokensAndAddLiquidity. */
    uint256 public constant SWAP_THRESHOLD_ETH_MAX = 50 ether;

    uint256 private constant _SHARE_LIQUIDITY = 70;
    uint256 private constant _MAX_SUPPLY = 8_888_888_888 ether;
    uint256 private constant _SUPPLY_LIQUIDITY =
        (_MAX_SUPPLY * _SHARE_LIQUIDITY) / 100;
    uint256 private constant _LAUNCH_BUY_TAX = 0;
    uint256 private constant _LAUNCH_SELL_TAX = 69_00;

    /** @notice Tax recipient wallet. */
    address public taxRecipient;
    /** @notice Whether address is extempt from transfer tax. */
    mapping(address => bool) public taxFreeAccount;
    /** @notice Whether address is an exchange pool. */
    mapping(address => bool) public isExchangePool;
    /** @notice Threshold in ETH of tokens to collect before triggering #swapTokensAndAddLiquidity. */
    uint256 public swapThresholdEth = 0.1 ether;
    /** @notice Tax manager. @dev Can **NOT** change transfer taxes. */
    address public taxManager;
    /** @notice Buy tax in bps (4.20%). In first hour after adding liquidity, buy tax will be #_LAUNCH_BUY_TAX. */
    uint256 public buyTax = 4_20;
    /** @notice Sell tax in bps (6.9%). In first hour after adding liquidity, sell tax will be #_LAUNCH_SELL_TAX. */
    uint256 public sellTax = 6_90;

    uint256 private _launchTaxEndsAt = type(uint256).max;


    event TaxRecipientChanged(address indexed taxRecipient);
    event SwapThresholdChanged(uint256 swapThresholdEth);
    event TaxFreeStateChanged(address indexed account, bool indexed taxFree);
    event ExchangePoolStateChanged(
        address indexed account,
        bool indexed isExchangePool
    );
    event TaxManagerChanged(address indexed taxManager);
    event TaxesChanged(uint256 newBuyTax, uint256 newSellTax);
    event TaxesWithdrawn(uint256 amount);

    error Unauthorized();
    error InvalidParameters();
    error InvalidSwapThreshold();
    error InvalidTax();

    modifier onlyTaxManager() {
        if (msg.sender != taxManager) {
            revert Unauthorized();
        }
        _;
    }

    constructor(
        address _owner,
        address _taxRecipient,
        address _taxManager
    ) ERC20("Pepeland", "Pepeland") {
        _transferOwnership(_owner);

        taxManager = _taxManager;
        emit TaxManagerChanged(_taxManager);
        taxRecipient = _taxRecipient;
        emit TaxRecipientChanged(_taxRecipient);

        taxFreeAccount[_taxRecipient] = true;
        emit TaxFreeStateChanged(_taxRecipient, true);
        taxFreeAccount[address(this)] = true;
        emit TaxFreeStateChanged(address(this), true);
        isExchangePool[pair] = true;
        emit ExchangePoolStateChanged(pair, true);
        emit TaxesChanged(buyTax, sellTax);

        _mint(address(this), _SUPPLY_LIQUIDITY);
        _mint(_taxRecipient, _MAX_SUPPLY - _SUPPLY_LIQUIDITY);
    }

    // *** Owner Interface ***

    /**
     * @notice Launch the token by providing liquidity.
     * @dev Only callable by owner, renounces ownership.
     */
    function launch() external payable onlyOwner {
        _addInitialLiquidityEth(_SUPPLY_LIQUIDITY, msg.value, msg.sender);

        _launchTaxEndsAt = block.timestamp + 60 minutes;

        renounceOwnership();
    }

    // *** Tax Manager Interface ***

    /**
     * @notice Set `taxFree` state of `account`.
     * @param account account
     * @param taxFree true if `account` should be extempt from transfer taxes.
     * @dev Only callable by taxManager.
     */
    function setTaxFreeAccount(
        address account,
        bool taxFree
    ) external onlyTaxManager {
        if (taxFreeAccount[account] == taxFree) {
            revert InvalidParameters();
        }
        taxFreeAccount[account] = taxFree;
        emit TaxFreeStateChanged(account, taxFree);
    }

    /**
     * @notice Set `exchangePool` state of `account`
     * @param account account
     * @param exchangePool whether `account` is an exchangePool
     * @dev ExchangePool state is used to decide if transfer is a swap
     * and should trigger #swapTokensAndAddLiquidity.
     */
    function setExchangePool(
        address account,
        bool exchangePool
    ) external onlyTaxManager {
        if (isExchangePool[account] == exchangePool) {
            revert InvalidParameters();
        }
        isExchangePool[account] = exchangePool;
        emit ExchangePoolStateChanged(account, exchangePool);
    }

    /**
     * @notice Transfer taxManager role to `newTaxManager`.
     * @param newTaxManager new taxManager
     * @dev Only callable by taxManager.
     */
    function transferTaxManager(address newTaxManager) external onlyTaxManager {
        if (newTaxManager == taxManager) {
            revert InvalidParameters();
        }
        taxManager = newTaxManager;
        emit TaxManagerChanged(newTaxManager);
    }

    /**
     * @notice Set taxRecipient address to `newTaxRecipient`.
     * @param newTaxRecipient new taxRecipient
     * @dev Only callable by taxManager.
     */
    function setTaxRecipient(address newTaxRecipient) external onlyTaxManager {
        if (newTaxRecipient == taxRecipient) {
            revert InvalidParameters();
        }
        taxRecipient = newTaxRecipient;
        emit TaxRecipientChanged(newTaxRecipient);
    }

    /**
     * @notice Withdraw tax collected (which would usually be automatically swapped to weth) to taxRecipient
     * @dev Only callable by taxManager.
     */
    function withdrawTaxes() external onlyTaxManager {
        uint256 balance = balanceOf(address(this));
        if (balance > 0) {
            super._transfer(address(this), taxRecipient, balance);
            emit TaxesWithdrawn(balance);
        }
    }

    /**
     * @notice Change the amount of tokens collected via tax before a swap is triggered.
     * @param newSwapThresholdEth new threshold received in ETH
     * @dev Only callable by taxManager
     */
    function setSwapThresholdEth(
        uint256 newSwapThresholdEth
    ) external onlyTaxManager {
        if (
            newSwapThresholdEth < SWAP_THRESHOLD_ETH_MIN ||
            newSwapThresholdEth > SWAP_THRESHOLD_ETH_MAX ||
            newSwapThresholdEth == swapThresholdEth
        ) {
            revert InvalidSwapThreshold();
        }
        swapThresholdEth = newSwapThresholdEth;
        emit SwapThresholdChanged(newSwapThresholdEth);
    }

    /**
     * @notice Set tax for buying and selling the token
     * @param newBuyTax new buy tax in bps
     * @param newSellTax new sell tax in bps
     * @dev Only callable by taxManager
     */
    function lowerTaxes(
        uint256 newBuyTax,
        uint256 newSellTax
    ) external onlyTaxManager {
        if (
            newBuyTax >= buyTax ||
            newSellTax >= sellTax
        ) {
            revert InvalidTax();
        }
        buyTax = newBuyTax;
        sellTax = newSellTax;
        emit TaxesChanged(newBuyTax, newSellTax);
    }

    /**
     * @notice Threshold of how many tokens to collect from tax before calling #swapTokens.
     * @dev Depends on swapThresholdEth which can be configured by taxManager.
     * Restricted to 5% of liquidity.
     */
    function swapThresholdToken() public view returns (uint256) {
        (uint reserveToken, uint reserveWeth) = _getReserve();
        uint256 maxSwapEth = (reserveWeth * 5) / 100;
        return
            _getAmountToken(
                swapThresholdEth > maxSwapEth ? maxSwapEth : swapThresholdEth,
                reserveToken,
                reserveWeth
            );
    }

    // *** Internal Interface ***

    /** @notice IERC20#_transfer */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        if (
            !taxFreeAccount[from] &&
            !taxFreeAccount[to] &&
            !taxFreeAccount[msg.sender]
        ) {
            uint256 fee = (amount *
                (
                    isExchangePool[from] /* buying */
                        ? (
                            block.timestamp > _launchTaxEndsAt
                                ? _LAUNCH_BUY_TAX
                                : buyTax
                        )
                        : (
                            block.timestamp > _launchTaxEndsAt
                                ? _LAUNCH_SELL_TAX
                                : sellTax
                        )
                )) / 100_00;
            super._transfer(from, address(this), fee);
            unchecked {
                amount -= fee;
            }

            if (isExchangePool[to]) /* selling */ {
                _swapTokens(swapThresholdToken());
            }
        }
        super._transfer(from, to, amount);
    }

    /** @dev Transfeer `amount` tokens from contract balance to `to`. */
    function _transferFromContractBalance(
        address to,
        uint256 amount
    ) internal override {
        super._transfer(address(this), to, amount);
    }

    /**
     * @notice Swap `amountToken` collected from tax to WETH to add to send to taxRecipient.
     */
    function _swapTokens(uint256 amountToken) internal {
        if (balanceOf(address(this)) < amountToken) {
            return;
        }

        _swapForWETH(amountToken, taxRecipient);
    }
}
