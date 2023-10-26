// SPDX-License-Identifier: MIT


pragma solidity ^0.6.2;

import './ERC20.sol';
import './Ownable.sol';
import './SafeMath.sol';
import './IUniswapV2Router02.sol';
import './IUniswapV2Factory.sol';
import './DividendTracker.sol';




contract IgnoreFudETH is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router; // Using current standard DEX Router Interface
    address public  uniswapV2Pair;

    bool private swapping;

    IgnoreFudDividendTracker public dividendTracker;

    address constant public deadWallet = 0x000000000000000000000000000000000000dEaD;
    address public fundWallet;
    address public MINTER;

    address public  RewardToken = address(0xdAC17F958D2ee523a2206206994597C13D831ec7); //RewardToken

    uint256 public swapTokensAtAmount;
    

    uint256 public RewardTokenFee = 3;
    uint256 public liquidityFee = 2;
    uint256 public burnFee = 2;
    uint256 public ecoSystemFee = 1;
    uint256 public totalFees = RewardTokenFee.add(liquidityFee).add(burnFee).add(ecoSystemFee);
    uint lastAddedTokens;
    uint lastAddedETH;
    uint lastAddedLiquidity;

    //address public _marketingWalletAddress = address(0);


    // use by default 300,000 gas to process auto-claiming dividends
    uint256 public gasForProcessing = 300000;

     // exlcude from fees and max transaction amount
    mapping (address => bool) private _isExcludedFromFees;


    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping (address => bool) public automatedMarketMakerPairs;

    event UpdateDividendTracker(address indexed newAddress, address indexed oldAddress);

    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event LiquidityWalletUpdated(address indexed newLiquidityWallet, address indexed oldLiquidityWallet);

    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event SwapAndSendFunds(uint256 tokens, address wallet);

    event SendDividends(
    	uint256 tokensSwapped,
    	uint256 amount
    );

    event ProcessedDividendTracker(
    	uint256 iterations,
    	uint256 claims,
        uint256 lastProcessedIndex,
    	bool indexed automatic,
    	uint256 gas,
    	address indexed processor
    );

    event RewardTokenFeeUpdated(uint256 indexed newRewardTokenFee);

    event LiquidityFeeUpdated(uint256 indexed newLiquidityFee);

    event EcoSystemFeeUpdated(uint256 indexed newEcoSystemFee);

    event BurnFeeUpdated(uint256 indexed newBurnFee);

constructor(address payable _fundWallet, address _minter) public ERC20("Ignore Fud", "4TOKEN") {

      fundWallet = _fundWallet;
      MINTER = _minter;

    	dividendTracker = new IgnoreFudDividendTracker();

        
    	IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xf164fC0Ec4E93095b804a4795bBe1e041497b92a);
         // Create a uniswap pair for this new token
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        swapTokensAtAmount = 4 * 10**6 * (10**18);

        // exclude from receiving dividends
        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(owner());
        dividendTracker.excludeFromDividends(deadWallet);
        dividendTracker.excludeFromDividends(address(0));
        dividendTracker.excludeFromDividends(address(_fundWallet));
        dividendTracker.excludeFromDividends(address(_uniswapV2Router));

        // exclude from paying fees or having max transaction amount
        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(_fundWallet), true);

    }

    receive() external payable {

  	}

    modifier onlyMinter(){
        require(_msgSender()==MINTER,"Must be the minter!");
        _;
    }

    function updateDividendTracker(address newAddress) public onlyOwner {
        require(newAddress != address(dividendTracker), "IgnoreFud: The dividend tracker already has that address");

        IgnoreFudDividendTracker newDividendTracker = IgnoreFudDividendTracker(payable(newAddress));

        require(newDividendTracker.owner() == address(this), "IgnoreFud: The new dividend tracker must be owned by the IgnoreFud token contract");

        newDividendTracker.excludeFromDividends(address(newDividendTracker));
        newDividendTracker.excludeFromDividends(address(this));
        newDividendTracker.excludeFromDividends(owner());
        newDividendTracker.excludeFromDividends(address(uniswapV2Router));
        newDividendTracker.excludeFromDividends(deadWallet);
        newDividendTracker.excludeFromDividends(address(0));
        newDividendTracker.excludeFromDividends(address(fundWallet));

        emit UpdateDividendTracker(newAddress, address(dividendTracker));

        dividendTracker = newDividendTracker;
    }

    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(uniswapV2Router), "IgnoreFud: The router already has that address");
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Pair = _uniswapV2Pair;
        _setAutomatedMarketMakerPair(uniswapV2Pair, true); //Not working in constructor
        dividendTracker.excludeFromDividends(address(uniswapV2Router)); //Not working in constructor
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "IgnoreFud: Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function excludeMultipleAccountsFromFees(address[] memory accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }

        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    function mint(address payable to, uint256 amount) external onlyMinter {
        _mint(to, amount);
        try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {
            revert("Couldn't set balance");
        }
    }

    function burn(address payable from, uint256 amount) external onlyMinter {
        _burn(from, amount);
        try dividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {
            revert("Couldn't set balance");
        }
    }


    function setRewardTokenFee(uint256 value) external onlyOwner{
        require(value.add(liquidityFee).add(burnFee).add(ecoSystemFee)<=8,"IgnoreFud: Maximum tax is 8%");
        RewardTokenFee = value;
        totalFees = RewardTokenFee.add(liquidityFee).add(burnFee).add(ecoSystemFee);
        emit RewardTokenFeeUpdated(value);
    }

    function setLiquidityFee(uint256 value) external onlyOwner{
        require(RewardTokenFee.add(value).add(burnFee).add(ecoSystemFee)<=8,"IgnoreFud: Maximum tax is 8%");
        liquidityFee = value;
        totalFees = RewardTokenFee.add(liquidityFee).add(burnFee).add(ecoSystemFee);
        emit LiquidityFeeUpdated(value);
    }

    function setEcoSystemFee(uint256 value) external onlyOwner{
        require(RewardTokenFee.add(liquidityFee).add(burnFee).add(value)<=8,"IgnoreFud: Maximum tax is 8%");
        ecoSystemFee = value;
        totalFees = RewardTokenFee.add(liquidityFee).add(burnFee).add(ecoSystemFee);
        emit EcoSystemFeeUpdated(value);
    }

    function setBurnFee(uint256 value) external onlyOwner{
        require(RewardTokenFee.add(liquidityFee).add(value).add(ecoSystemFee)<=8,"IgnoreFud: Maximum tax is 8%");
        burnFee = value;
        totalFees = RewardTokenFee.add(liquidityFee).add(burnFee).add(ecoSystemFee);
        emit BurnFeeUpdated(value);
    }


    function setSwapLimit(uint256 value) external onlyOwner{
        swapTokensAtAmount = value*(10**18);
    }
    
 
    // We are planning to change the reward token on community voting.

    function setRewardToken(address _rewardToken) external onlyOwner{
        RewardToken = _rewardToken;
        dividendTracker.updateRewardToken(_rewardToken);
    }


    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "IgnoreFud: The IgnoreFud-BNB pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(pair, value);
    }
    

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "IgnoreFud: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;

        if(value) {
            dividendTracker.excludeFromDividends(pair);
        }

        emit SetAutomatedMarketMakerPair(pair, value);
    }
    

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, "IgnoreFud: gasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "IgnoreFud: Cannot update gasForProcessing to same value");
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }

    function updateClaimWait(uint256 claimWait) external onlyOwner {
        dividendTracker.updateClaimWait(claimWait);
    }

    function getClaimWait() external view returns(uint256) {
        return dividendTracker.claimWait();
    }

    function getTotalDividendsDistributed() external view returns (uint256) {
        return dividendTracker.totalDividendsDistributed();
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function withdrawableDividendOf(address account) public view returns(uint256) {
    	return dividendTracker.withdrawableDividendOf(account);
  	}

	function dividendTokenBalanceOf(address account) public view returns (uint256) {
		return dividendTracker.balanceOf(account);
	}

	function excludeFromDividends(address account) external onlyOwner{
	    dividendTracker.excludeFromDividends(account);
	}
 

    function getAccountDividendsInfo(address account)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
        return dividendTracker.getAccount(account);
    }

	function getAccountDividendsInfoAtIndex(uint256 index)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
    	return dividendTracker.getAccountAtIndex(index);
    }

	function processDividendTracker(uint256 gas) external {
		(uint256 iterations, uint256 claims, uint256 lastProcessedIndex) = dividendTracker.process(gas);
		emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, false, gas, tx.origin);
    }

    function claim() external {
		require(dividendTracker.processAccount(msg.sender, false),"No rewards to claim!");
    }

    function getLastProcessedIndex() external view returns(uint256) {
    	return dividendTracker.getLastProcessedIndex();
    }

    function getNumberOfDividendTokenHolders() external view returns(uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }


    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

		uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if( canSwap &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            from != owner() &&
            to != owner()
        ) {
            swapping = true;


            uint256 swapTokens = contractTokenBalance.mul(liquidityFee).div(totalFees);
            uint256 burnTokens = contractTokenBalance.mul(burnFee).div(totalFees);
            uint256 ecoSystemTokens = contractTokenBalance.mul(ecoSystemFee).div(totalFees);
            swapAndLiquify(swapTokens);
            swapAndSendForFunds(ecoSystemTokens);
            _burn(address(this),burnTokens);

            uint256 sellTokens = balanceOf(address(this));
            swapAndSendDividends(sellTokens);

            swapping = false;
        }


        bool takeFee;


        if( automatedMarketMakerPairs[to]) {
            takeFee = true;
        }
        else{
            takeFee = false;
        }

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if(takeFee) {
        	uint256 fees = amount.mul(totalFees).div(100);
        	amount = amount.sub(fees);

            super._transfer(from, address(this), fees);
        }

        super._transfer(from, to, amount);

        try dividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {
            // No action is implemented here because if the process failed then the token will be transferred and 
            // dividends will be processed at next transfer as the processing dividends is integrated into this function.
        }
        try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {
            // No action is implemented here because if the process failed then the token will be transferred and 
            // dividends will be processed at next transfer as the processing dividends is integrated into this function.
        }

        if(!swapping) {
	    	uint256 gas = gasForProcessing;

	    	try dividendTracker.process(gas) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
	    		emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gas, tx.origin);
	    	}
	    	catch {
                // No action is implemented here because if the process failed then the token will be transferred and 
                // dividends will be processed at next transfer.
	    	}
        }
    }


    function swapAndLiquify(uint256 tokens) private {
       // split the contract balance into halves
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);
        uint256 ethBalanceBefore = address(this).balance;


        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> IgnoreFud swap when swap+liquify is triggered

        uint256 ethBalanceAfter = address(this).balance;

        // how much ETH did we just swap into?
        uint256 newBalanceETH = ethBalanceAfter.sub(ethBalanceBefore);

        // add liquidity to uniswap
        addLiquidity(half, newBalanceETH);
        
        emit SwapAndLiquify(half, newBalanceETH, otherHalf);
    }


    function swapAndSendForFunds(uint256 tokens) private {
       // generate the uniswap pair path of weth -> token
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokens);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokens,
            0, // accept any amount of ETH
            path,
            fundWallet,
            block.timestamp
        );

        emit SwapAndSendFunds(tokens, fundWallet);
    }

    function swapTokensForEth(uint256 tokenAmount) private {


        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );

    }

    function sweep(uint256 ethAmount) external onlyOwner {

        (bool success,) = fundWallet.call{value:ethAmount}(new bytes(0));
        require(success, 'ETH_TRANSFER_FAILED');

    }

    function swapTokensForRewardToken(uint256 tokenAmount) private {

        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = RewardToken;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of Tokens
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {

        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        (lastAddedTokens, lastAddedETH, lastAddedLiquidity)=uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(0),
            block.timestamp
        );

    }


    function swapAndSendDividends(uint256 tokens) private{
        swapTokensForRewardToken(tokens);
        uint256 dividends = IERC20(RewardToken).balanceOf(address(this));
        bool success = IERC20(RewardToken).transfer(address(dividendTracker), dividends);

        if (success) {
            dividendTracker.distributeRewardTokenDividends(dividends);
            emit SendDividends(tokens, dividends);
        }
    }
}

