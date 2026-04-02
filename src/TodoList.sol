// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TodoList {
    struct Task {
        string content;
        bool isCompleted;
    }

    mapping(address => Task[]) private userTasks;

    event TaskCreated(address indexed user, uint256 taskId, string content);
    event TaskToggled(address indexed user, uint256 taskId, bool isCompleted);
    event TaskDeleted(address indexed user, uint256 taskId);

    error TodoList__InvalidTaskId();

    modifier validTaskId(uint256 taskId) {
        _validTaskId(taskId);
        _;
    }

    function _validTaskId(uint256 taskId) internal view {
        if (taskId >= userTasks[msg.sender].length) {
            revert TodoList__InvalidTaskId();
        }
    }

    function createTask(string memory content) public {
        userTasks[msg.sender].push(Task({content: content, isCompleted: false}));
        uint256 taskId = userTasks[msg.sender].length - 1;
        emit TaskCreated(msg.sender, taskId, content);
    }

    function toggleTask(uint256 taskId) public validTaskId(taskId) {
        userTasks[msg.sender][taskId].isCompleted = !userTasks[msg.sender][taskId].isCompleted;
        emit TaskToggled(msg.sender, taskId, userTasks[msg.sender][taskId].isCompleted);
    }

    function getTask(uint256 taskId) public view validTaskId(taskId) returns (string memory, bool) {
        Task memory task = userTasks[msg.sender][taskId];
        return (task.content, task.isCompleted);
    }

    function getTaskCount() public view returns (uint256) {
        return userTasks[msg.sender].length;
    }

    function deleteTask(uint256 taskId) public validTaskId(taskId) {
        for (uint256 i = taskId; i < userTasks[msg.sender].length - 1; i++) {
            userTasks[msg.sender][i] = userTasks[msg.sender][i + 1];
        }
        userTasks[msg.sender].pop();
        emit TaskDeleted(msg.sender, taskId);
    }
}
