// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ApprovalRaceCondition {
    mapping(address => mapping(address => uint256)) public allowance;

    // Vulnerable approve function
    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external {
        require(allowance[from][msg.sender] >= amount, "Not enough allowance");
        allowance[from][msg.sender] -= amount;
        // transfer logic...
    }
}
