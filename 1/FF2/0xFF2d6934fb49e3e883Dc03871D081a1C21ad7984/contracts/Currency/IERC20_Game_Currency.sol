// SPDX-License-Identifier: Commons-Clause-1.0
//  __  __     _        ___     _
// |  \/  |___| |_ __ _| __|_ _| |__
// | |\/| / -_)  _/ _` | _/ _` | '_ \
// |_|  |_\___|\__\__,_|_|\__,_|_.__/
//
// Launch your crypto game or gamefi project's blockchain
// infrastructure & game APIs fast with https://trymetafab.com

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IERC20_Game_Currency is IERC20, IERC165  {
  // events
  event TransferRef(address indexed sender, address indexed recipient, uint256 amount, uint256 ref);
  event BatchTransferRef(address indexed sender, address[] recipients, uint256[] amounts, uint256[] refs);

  // autogenerated getters
  function feeBps() external view returns (uint);
  function feeFixed() external view returns (uint);
  function feeCap() external view returns (uint);
  function feeRecipient() external view returns (address);
  function childChainManagerProxy() external view returns (address);
  function supplyCap() external view returns (uint256);

  // functions
  function mint(address _to, uint256 _amount) external;
  function burn(uint256 _amount) external;
  function transferWithRef(address recipient, uint256 amount, uint256 ref) external returns (bool);
  function batchTransfer(address[] calldata recipients, uint256[] calldata amounts) external returns (bool);
  function batchTransferWithRefs(address[] calldata recipients, uint256[] calldata amounts, uint256[] calldata refs) external returns (bool);
  function batchTransferWithFees(address[] calldata recipients, uint256[] calldata amounts) external returns (bool);
  function batchTransferWithFeesRefs(address[] calldata recipients, uint256[] calldata amounts, uint256[] calldata refs) external returns (bool);
  function deposit(address user, bytes calldata depositData) external;
  function withdraw(uint256 amount) external;
  function updateChildChainManager(address _childChainManagerProxy) external;
  function burnWithFee(uint256 amount) external returns (bool);
  function transferWithFee(address recipient, uint256 amount) external returns (bool);
  function transferWithFeeRef(address recipient, uint256 amount, uint256 ref) external returns (bool);
  function setFees(address recipient, uint _feeBps, uint _feeFixed, uint _feeCap) external;
}
