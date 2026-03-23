// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {TodoList} from "../src/TodoList.sol";

contract TodoListTest is Test {
    TodoList public todo_list;

    address public alice = address(0x1);
    address public bob = address(0x2);

    event TaskCreated(address indexed user, uint256 task_id, string content);
    event TaskToggled(address indexed user, uint256 task_id, bool is_completed);
    event TaskDeleted(address indexed user, uint256 task_id);

    function setUp() public {
        todo_list = new TodoList();
    }

    function test_create_task_and_get_count() public {
        vm.startPrank(alice);
        vm.expectEmit(true, false, false, true, address(todo_list));
        emit TaskCreated(alice, 0, "Learn Foundry");
        todo_list.create_task("Learn Foundry");
        assertEq(todo_list.get_task_count(), 1);
        (string memory content, bool is_completed) = todo_list.get_task(0);
        assertEq(content, "Learn Foundry");
        assertFalse(is_completed);
        vm.stopPrank();
    }

    function test_users_have_isolated_lists() public {
        vm.prank(alice);
        todo_list.create_task("Alice's Task");
        vm.prank(bob);
        todo_list.create_task("Bob's Task");
        vm.prank(alice);
        assertEq(todo_list.get_task_count(), 1);
        vm.prank(bob);
        assertEq(todo_list.get_task_count(), 1);
    }

    function test_toggle_task_changes_status() public {
        vm.startPrank(alice);
        todo_list.create_task("Write Tests");
        vm.expectEmit(true, false, false, true, address(todo_list));
        emit TaskToggled(alice, 0, true);
        todo_list.toggle_task(0);
        (, bool is_completed) = todo_list.get_task(0);
        assertTrue(is_completed);
        vm.stopPrank();
    }

    function test_revert_on_invalid_task_id() public {
        vm.startPrank(alice);
        vm.expectRevert(TodoList.TodoList__InvalidTaskId.selector);
        todo_list.get_task(0);
        vm.stopPrank();
    }

    function test_delete_task_shifts_array() public {
        vm.startPrank(alice);
        todo_list.create_task("Task 0");
        todo_list.create_task("Task 1");
        todo_list.create_task("Task 2");
        vm.expectEmit(true, false, false, true, address(todo_list));
        emit TaskDeleted(alice, 1);
        todo_list.delete_task(1);
        assertEq(todo_list.get_task_count(), 2);
        (string memory content, ) = todo_list.get_task(1);
        assertEq(content, "Task 2");
        vm.stopPrank();
    }
}
