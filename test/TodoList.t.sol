// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {TodoList} from "../src/TodoList.sol";

contract TodoListTest is Test {
    TodoList public todoList;

    address public alice = address(0x1);
    address public bob = address(0x2);

    event TaskCreated(address indexed user, uint256 taskId, string content);
    event TaskToggled(address indexed user, uint256 taskId, bool isCompleted);
    event TaskDeleted(address indexed user, uint256 taskId);

    function setUp() public {
        todoList = new TodoList();
    }

    function test_CreateTaskAndGetCount() public {
        vm.startPrank(alice);
        vm.expectEmit(true, false, false, true, address(todoList));
        emit TaskCreated(alice, 0, "Learn Foundry");
        todoList.createTask("Learn Foundry");
        assertEq(todoList.getTaskCount(), 1);
        (string memory content, bool isCompleted) = todoList.getTask(0);
        assertEq(content, "Learn Foundry");
        assertFalse(isCompleted);
        vm.stopPrank();
    }

    function test_UsersHaveIsolatedLists() public {
        vm.prank(alice);
        todoList.createTask("Alice's Task");
        vm.prank(bob);
        todoList.createTask("Bob's Task");
        vm.prank(alice);
        assertEq(todoList.getTaskCount(), 1);
        vm.prank(bob);
        assertEq(todoList.getTaskCount(), 1);
    }

    function test_ToggleTaskChangesStatus() public {
        vm.startPrank(alice);
        todoList.createTask("Write Tests");
        vm.expectEmit(true, false, false, true, address(todoList));
        emit TaskToggled(alice, 0, true);
        todoList.toggleTask(0);
        (, bool isCompleted) = todoList.getTask(0);
        assertTrue(isCompleted);
        vm.stopPrank();
    }

    function test_RevertOnInvalidTaskId() public {
        vm.startPrank(alice);
        vm.expectRevert(TodoList.TodoList__InvalidTaskId.selector);
        todoList.getTask(0);
        vm.stopPrank();
    }

    function test_DeleteTaskShiftsArray() public {
        vm.startPrank(alice);
        todoList.createTask("Task 0");
        todoList.createTask("Task 1");
        todoList.createTask("Task 2");
        vm.expectEmit(true, false, false, true, address(todoList));
        emit TaskDeleted(alice, 1);
        todoList.deleteTask(1);
        assertEq(todoList.getTaskCount(), 2);
        (string memory content,) = todoList.getTask(1);
        assertEq(content, "Task 2");
        vm.stopPrank();
    }
}
