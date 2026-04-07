// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TxOriginVulnerable {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function transfer(address to, uint256 amount) external {
        // Vulnerable: uses tx.origin
        require(tx.origin == owner, "Not owner");
        payable(to).transfer(amount);
    }
}
