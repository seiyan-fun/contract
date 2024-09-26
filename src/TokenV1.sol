pragma solidity ^0.8.13;

import "./interfaces/ITokenV1.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

contract TokenV1 is ITokenV1, ERC20Upgradeable {
    address public bond;
    address public dragonswapPair;
    bool public isListed;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    modifier onlyBond() {
        if (bond != _msgSender()) revert UnauthorizedBond(_msgSender());
        _;
    }

    modifier onlyNotListed() {
        if (isListed) revert AlreadyListed();
        _;
    }

    function initialize(
        address _bond,
        address _dragonswapPair,
        string memory _name,
        string memory _symbol
    ) external initializer {
        require(bond == address(0), "Already initialized");
        require(_bond != address(0), "bond address cannot be zero");
        require(_dragonswapPair != address(0), "pair address cannot be zero address");
        bond = _bond;
        dragonswapPair = _dragonswapPair;
        isListed = false;
        __ERC20_init(_name, _symbol);
    }

    function transfer(address to, uint256 value) public override(IERC20, ERC20Upgradeable) returns (bool) {
        if (!isListed && to == dragonswapPair) {
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
    ) public override(IERC20, ERC20Upgradeable) returns (bool) {
        if (!isListed && to == dragonswapPair) {
            revert("not listed token could not be transfer to dragon swap lp");
        }
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        emit TransferEvent(from, to, value, balanceOf(from), balanceOf(to), totalSupply(), block.timestamp);
        return true;
    }

    function getBond() public view returns (address) {
        return bond;
    }

    function mintByBond(address to, uint256 amount) external onlyBond onlyNotListed {
        if (totalSupply() + amount > 1000000000 ether) {
            revert TotalSupplyMaximumExceeded();
        }
        _mint(to, amount);
        emit TransferEvent(address(0x0), to, amount, 0, balanceOf(to), totalSupply(), block.timestamp);
    }

    function burnByBond(address account, uint256 amount) external onlyBond onlyNotListed {
        _burn(account, amount);
        emit TransferEvent(account, address(0x0), amount, balanceOf(account), 0, totalSupply(), block.timestamp);
    }

    function decimals() public pure override(ITokenV1, ERC20Upgradeable) returns (uint8) {
        return 18;
    }

    function getDragonswapPair() public view returns (address) {
        return dragonswapPair;
    }

    function list() public onlyBond returns (bool) {
        require(!isListed, "already listed");
        isListed = true;
        return isListed;
    }
}
