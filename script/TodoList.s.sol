// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {TodoList} from "../src/TodoList.sol";

contract TodoListScript is Script {
    TodoList public todo_list;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        todo_list = new TodoList();
        vm.stopBroadcast();
    }
}
