// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ITokenV1Legacy is IERC20 {
    error UnauthorizedBond(address account);

    error AlreadyListed();

    error TotalSupplyMaximumExceeded();

    event BondUpdated(address indexed oldBond, address indexed newBond);

    event TransferEvent(
        address indexed from,
        address indexed to,
        uint256 value,
        uint256 fromBalance,
        uint256 toBalance,
        uint256 totalBalance,
        uint256 blockTimestamp
    );

    function decimals() external view returns (uint8);

    function isListed() external view returns (bool);

    function mintByBond(address to, uint256 amount) external;

    function burnByBond(address account, uint256 amount) external;

    function list() external returns (bool);
}
