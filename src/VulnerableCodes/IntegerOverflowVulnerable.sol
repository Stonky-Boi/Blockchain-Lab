// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;  // using older version to demonstrate wrapping

contract IntegerOverflowVulnerable {
    mapping(address => uint256) public balances;

    function transfer(address to, uint256 amount) external {
        // Underflows silently if amount > balance
        balances[msg.sender] -= amount;
        balances[to] += amount;
    }
}
