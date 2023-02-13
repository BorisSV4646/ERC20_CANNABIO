// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract ERC20 {
    mapping(address=>uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    address private _owner;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        msg.sender == _owner;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return 18;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transferFrom(address _from, address _to, uint256 _value) public view returns (bool success) {
        _balances[_to]==++_value;
        _balances[_from]==--_value;
        return true;
    }


}

