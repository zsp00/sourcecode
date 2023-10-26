// SPDX-License-Identifier: MIT
pragma solidity =0.8.11;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.5/contracts/token/ERC20/IERC20.sol";
import "../interfaces/IUniswap.sol";

library Liquidity {
    address public constant FACTORY =
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address public constant ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant DEAD_ADDRESS =
        0x000000000000000000000000000000000000dEaD;

    function swap(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _slippage,
        address _to
    ) internal returns (uint256) {
        IERC20(_tokenIn).approve(ROUTER, _amountIn);

        address[] memory path;
        if (_tokenIn == WETH || _tokenOut == WETH) {
            path = new address[](2);
            path[0] = _tokenIn;
            path[1] = _tokenOut;
        } else {
            path = new address[](3);
            path[0] = _tokenIn;
            path[1] = WETH;
            path[2] = _tokenOut;
        }

        uint256 _amountOutMin = (IUniswapV2Router(ROUTER).getAmountsOut(
            _amountIn,
            path
        )[path.length - 1] * (1000 - _slippage)) / 1000;

        uint256 balanceBefore = IERC20(_tokenOut).balanceOf(_to);
        IUniswapV2Router(ROUTER)
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                _amountIn,
                _amountOutMin,
                path,
                _to,
                block.timestamp
            );
        uint256 balanceAfter = IERC20(_tokenOut).balanceOf(_to);
        return balanceAfter - balanceBefore;
    }

    function getPair(
        address _tokenA,
        address _tokenB
    ) internal view returns (address) {
        return IUniswapV2Factory(FACTORY).getPair(_tokenA, _tokenB);
    }
}
