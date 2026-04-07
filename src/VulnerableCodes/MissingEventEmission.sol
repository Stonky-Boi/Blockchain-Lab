// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MissingEventEmission {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) external {
        require(msg.sender == owner, "Not owner");
        // BUG: no event emitted – off-chain systems cannot track change
        owner = newOwner;
    }
}