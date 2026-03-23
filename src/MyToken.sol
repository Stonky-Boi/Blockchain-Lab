// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MyToken {
    string public name = "MyToken";
    string public symbol = "MTK";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    address public owner;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    error MyToken__InsufficientBalance();
    error MyToken__InsufficientAllowance();
    error MyToken__NotOwner();
    error MyToken__InvalidAddress();

    modifier only_owner() {
        if (msg.sender != owner) {
            revert MyToken__NotOwner();
        }
        _;
    }

    constructor(uint256 initial_supply) {
        owner = msg.sender;
        _mint(msg.sender, initial_supply);
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        if (to == address(0)) revert MyToken__InvalidAddress();
        if (balanceOf[msg.sender] < amount)
            revert MyToken__InsufficientBalance();
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        if (spender == address(0)) revert MyToken__InvalidAddress();
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        if (to == address(0)) revert MyToken__InvalidAddress();
        if (balanceOf[from] < amount) revert MyToken__InsufficientBalance();
        if (allowance[from][msg.sender] < amount)
            revert MyToken__InsufficientAllowance();
        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function _mint(address to, uint256 amount) internal {
        if (to == address(0)) revert MyToken__InvalidAddress();
        totalSupply += amount;
        balanceOf[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    function mint(address to, uint256 amount) public only_owner {
        _mint(to, amount);
    }
}
