// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UncheckedExternalCall {
    uint256 public totalSent;

    function sendFunds(address payable to, uint256 amount) external {
        // BUG: return value not checked; transfer may fail silently
        to.call{value: amount}("");
        totalSent += amount; // state updated even if ETH transfer failed
    }
}
