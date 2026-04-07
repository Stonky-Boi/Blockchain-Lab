// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TimestampDependent {
    uint256 public constant RELEASE_TIME = 1_700_000_000; // some future timestamp

    function withdraw() external {
        // Vulnerable: block.timestamp can be slightly manipulated by validator
        require(block.timestamp >= RELEASE_TIME, "Too early");
        payable(msg.sender).transfer(address(this).balance);
    }
}