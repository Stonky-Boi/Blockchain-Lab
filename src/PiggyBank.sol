// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PiggyBank {
    mapping(address => uint256) public balances;
    mapping(address => uint256) public lock_times;

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    error PiggyBank__InsufficientBalance();
    error PiggyBank__TransferFailed();
    error PiggyBank__FundsLocked(uint256 unlock_time);
    error PiggyBank__InvalidLockTime();

    function deposit() public payable {
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    function lock_funds(uint256 unlock_time) public {
        if (unlock_time <= block.timestamp) {
            revert PiggyBank__InvalidLockTime();
        }
        if (unlock_time > lock_times[msg.sender]) {
            lock_times[msg.sender] = unlock_time;
        }
    }

    function withdraw(uint256 amount) public {
        if (balances[msg.sender] < amount) {
            revert PiggyBank__InsufficientBalance();
        }
        if (block.timestamp < lock_times[msg.sender]) {
            revert PiggyBank__FundsLocked(lock_times[msg.sender]);
        }
        balances[msg.sender] -= amount;
        emit Withdrawn(msg.sender, amount);
        (bool success, ) = msg.sender.call{value: amount}("");
        if (!success) {
            revert PiggyBank__TransferFailed();
        }
    }
}
