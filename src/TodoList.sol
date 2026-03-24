// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TodoList {
    struct Task {
        string content;
        bool is_completed;
    }

    mapping(address => Task[]) private user_tasks;

    event TaskCreated(address indexed user, uint256 task_id, string content);
    event TaskToggled(address indexed user, uint256 task_id, bool is_completed);
    event TaskDeleted(address indexed user, uint256 task_id);

    error TodoList__InvalidTaskId();

    modifier valid_task_id(uint256 task_id) {
        if (task_id >= user_tasks[msg.sender].length) {
            revert TodoList__InvalidTaskId();
        }
        _;
    }

    function create_task(string memory content) public {
        user_tasks[msg.sender].push(Task({content: content, is_completed: false}));
        uint256 task_id = user_tasks[msg.sender].length - 1;
        emit TaskCreated(msg.sender, task_id, content);
    }

    function toggle_task(uint256 task_id) public valid_task_id(task_id) {
        user_tasks[msg.sender][task_id].is_completed = !user_tasks[msg.sender][task_id].is_completed;
        emit TaskToggled(msg.sender, task_id, user_tasks[msg.sender][task_id].is_completed);
    }

    function get_task(uint256 task_id) public view valid_task_id(task_id) returns (string memory, bool) {
        Task memory task = user_tasks[msg.sender][task_id];
        return (task.content, task.is_completed);
    }

    function get_task_count() public view returns (uint256) {
        return user_tasks[msg.sender].length;
    }

    function delete_task(uint256 task_id) public valid_task_id(task_id) {
        for (uint256 i = task_id; i < user_tasks[msg.sender].length - 1; i++) {
            user_tasks[msg.sender][i] = user_tasks[msg.sender][i + 1];
        }
        user_tasks[msg.sender].pop();
        emit TaskDeleted(msg.sender, task_id);
    }
}
