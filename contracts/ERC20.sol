// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";

/**
 * TODO: add vote function in token contract from Votes.sol
 */   
contract ERC20 is Context, IERC20 {
    address private _rewardPool;
    address private _creater;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    uint256 private _CAP = 1_500_000e18;
    uint256 private _feeBurn = 5;
    uint256 private _feeReward = 20;
    string private constant _NAME = "CANNABIO";
    string private constant _SYMBOL = "CNB";

    constructor(uint256 initialSupply, address rewardPool_) {
        require(_CAP > 0, "ERC20Capped: cap is 0");
        _mint(_msgSender(), initialSupply * (10 ** decimals()));
        _creater = msg.sender;
        _rewardPool = rewardPool_;
    }

    modifier onlyCreater {
        _creater = _msgSender();
        _;
    }

    function name() public view virtual returns (string memory) {
        return _NAME;
    }

    function symbol() public view virtual returns (string memory) {
        return _SYMBOL;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function cap() public view virtual returns (uint256) {
        return _CAP;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint feeBurn = _calcFeeburn(amount);
        uint feeReward = _calcFeereward(amount);

        // _beforeTokenTransfer(amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        require(amount + feeBurn + (feeReward/2)<= _balances[from], "ERC20: transfer amount exceeds balance");
        _burn(from, feeBurn);
        unchecked {
            _balances[from] -= amount - (feeReward/2);
            _balances[to] += amount;
            _balances[_rewardPool] += feeReward/2;
        }

        emit Transfer(from, to, amount, feeBurn, feeReward);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) public virtual onlyCreater {
        require(account != address(0), "ERC20: mint to the zero address");
        require(totalSupply() + amount <= cap(), "ERC20Capped: cap exceeded");

        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount, 0, 0);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            _CAP -= amount;
        }

        emit Transfer(account, address(0), amount, 0, 0);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _calcFeeburn(uint256 amount) internal view returns(uint feeBurn) {
        return (amount * _feeBurn / 1000);
    }

    function _calcFeereward(uint256 amount) internal view returns(uint feeBurn) {
        return (amount * _feeReward / 1000);
    }

//     function _beforeTokenTransfer(uint256 amount) internal virtual returns(uint feeBurn, uint feeReward) {
//         return ((amount * _feeBurn / 1000), (amount * _feeReward / 1000));
//     }

    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}