// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {SimpleStorage} from "../src/SimpleStorage.sol";

contract SimpleStorageTest is Test {
    SimpleStorage public simple_storage;
    address public owner = address(this);
    address public non_owner = address(0x1);

    event DataUpdated(uint256 oldValue, uint256 newValue);

    function setUp() public {
        simple_storage = new SimpleStorage();
    }

    function test_initial_value_is_zero() public view {
        assertEq(simple_storage.get(), 0);
    }

    function test_set_updates_value() public {
        simple_storage.set(42);
        assertEq(simple_storage.get(), 42);
    }

    function test_data_updated_event_is_emitted() public {
        vm.expectEmit(false, false, false, true, address(simple_storage));
        emit DataUpdated(0, 42);
        simple_storage.set(42);
    }

    function test_revert_when_not_owner_calls_set() public {
        vm.prank(non_owner);
        vm.expectRevert(SimpleStorage.SimpleStorage__NotOwner.selector);
        simple_storage.set(42);
    }

    function test_fuzz_set_updates_value(uint256 random_value) public {
        simple_storage.set(random_value);
        assertEq(simple_storage.get(), random_value);
    }
}
