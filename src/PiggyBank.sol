// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PiggyBank {
    mapping(address => uint256) public balances;
    mapping(address => uint256) public lockTimes;

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    error PiggyBank__InsufficientBalance();
    error PiggyBank__TransferFailed();
    error PiggyBank__FundsLocked(uint256 unlockTime);
    error PiggyBank__InvalidLockTime();

    function deposit() public payable {
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    function lockFunds(uint256 unlockTime) public {
        if (unlockTime <= block.timestamp) {
            revert PiggyBank__InvalidLockTime();
        }
        if (unlockTime > lockTimes[msg.sender]) {
            lockTimes[msg.sender] = unlockTime;
        }
    }

    function withdraw(uint256 amount) public {
        if (balances[msg.sender] < amount) {
            revert PiggyBank__InsufficientBalance();
        }
        if (block.timestamp < lockTimes[msg.sender]) {
            revert PiggyBank__FundsLocked(lockTimes[msg.sender]);
        }
        balances[msg.sender] -= amount;
        emit Withdrawn(msg.sender, amount);
        (bool success,) = msg.sender.call{value: amount}("");
        if (!success) {
            revert PiggyBank__TransferFailed();
        }
    }
}
