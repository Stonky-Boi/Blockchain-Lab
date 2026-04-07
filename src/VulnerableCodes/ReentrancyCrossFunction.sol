// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ReentrancyCrossFunction {
    mapping(address => uint256) public balances;
    bool public locked;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    // One entry point: withdraw
    function withdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0);
        // BUG: state not updated before external call
        (bool ok,) = msg.sender.call{value: amount}("");
        require(ok);
        balances[msg.sender] = 0;
    }

    // Another function that also interacts before state change
    function emergencyWithdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0);
        (bool ok,) = msg.sender.call{value: amount}("");
        require(ok);
        balances[msg.sender] = 0;
    }
}