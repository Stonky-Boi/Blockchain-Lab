// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AccessControlVulnerable {
    mapping(address => uint256) public balances;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // Anyone can mint themselves tokens!
    function mint(address to, uint256 amount) external {
        balances[to] += amount;
    }
}
