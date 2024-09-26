// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {ITokenV1Legacy} from "./interfaces/ITokenV1Legacy.sol";

contract TokenV1Legacy is Initializable, ITokenV1Legacy, ERC20Upgradeable {
    struct TokenV1Storage {
        address bond;
        address dragonswapPair;
        bool isListed;
    }

    // keccak256(abi.encode(uint256(keccak256("haechi.TokenV1")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 private constant TokenV1StorageLocation =
        0x645fc6f46b969d0474434cdd18adae82de7d092732df9f3fce3786ca58216100;

    function _getTokenV1Storage() private pure returns (TokenV1Storage storage $) {
        assembly {
            $.slot := TokenV1StorageLocation
        }
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    modifier onlyBond() {
        if (getBond() != _msgSender()) revert UnauthorizedBond(_msgSender());
        _;
    }

    modifier onlyNotListed() {
        if (isListed()) revert AlreadyListed();
        _;
    }

    function initialize(
        address bond,
        address dragonswapPair,
        string memory name,
        string memory symbol
    ) public initializer {
        __ERC20_init(name, symbol);
        _updateBond(bond);
        _setDragonswapPair(dragonswapPair);
    }

    function transfer(address to, uint256 value) public override(ERC20Upgradeable, IERC20) returns (bool) {
        if (!isListed() && to == getDragonswapPair()) {
            revert("not listed token could not be transfer to dragon swap lp");
        }
        address owner = _msgSender();
        _transfer(owner, to, value);
        emit TransferEvent(owner, to, value, balanceOf(owner), balanceOf(to), totalSupply(), block.timestamp);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public override(ERC20Upgradeable, IERC20) returns (bool) {
        if (!isListed() && to == getDragonswapPair()) {
            revert("not listed token could not be transfer to dragon swap lp");
        }
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        emit TransferEvent(from, to, value, balanceOf(from), balanceOf(to), totalSupply(), block.timestamp);
        return true;
    }

    function _updateBond(address newBond) private onlyInitializing {
        TokenV1Storage storage $ = _getTokenV1Storage();
        address oldBond = $.bond;
        $.bond = newBond;
        emit BondUpdated(oldBond, newBond);
    }

    function getBond() public view returns (address) {
        TokenV1Storage storage $ = _getTokenV1Storage();
        return $.bond;
    }

    function mintByBond(address to, uint256 amount) external onlyBond onlyNotListed {
        if (totalSupply() + amount > 1_000_000_000 * (10 ** decimals())) {
            revert TotalSupplyMaximumExceeded();
        }
        _mint(to, amount);
        emit TransferEvent(address(0x0), to, amount, 0, balanceOf(to), totalSupply(), block.timestamp);
    }

    function burnByBond(address account, uint256 amount) external onlyBond onlyNotListed {
        _burn(account, amount);
        emit TransferEvent(account, address(0x0), amount, balanceOf(account), 0, totalSupply(), block.timestamp);
    }

    function decimals() public pure override(ERC20Upgradeable, ITokenV1Legacy) returns (uint8) {
        return 18;
    }

    function isListed() public view returns (bool) {
        TokenV1Storage storage $ = _getTokenV1Storage();
        return $.isListed;
    }

    function getDragonswapPair() public view returns (address) {
        TokenV1Storage storage $ = _getTokenV1Storage();
        return $.dragonswapPair;
    }

    function _setDragonswapPair(address pair) private onlyInitializing {
        require(pair != address(0), "pair address cannot be zero address");
        TokenV1Storage storage $ = _getTokenV1Storage();
        $.dragonswapPair = pair;
    }

    function list() public onlyBond returns (bool) {
        TokenV1Storage storage $ = _getTokenV1Storage();
        require(!$.isListed, "already listed");
        $.isListed = true;
        return $.isListed;
    }
}
