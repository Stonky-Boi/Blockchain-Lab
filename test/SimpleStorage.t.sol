// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {SimpleStorage} from "../src/SimpleStorage.sol";

contract SimpleStorageTest is Test {
    SimpleStorage public simpleStorage;
    address public owner = address(this);
    address public nonOwner = address(0x1);

    event DataUpdated(uint256 oldValue, uint256 newValue);

    function setUp() public {
        simpleStorage = new SimpleStorage();
    }

    function test_InitialValueIsZero() public view {
        assertEq(simpleStorage.get(), 0);
    }

    function test_SetUpdatesValue() public {
        simpleStorage.set(42);
        assertEq(simpleStorage.get(), 42);
    }

    function test_DataUpdatedEventIsEmitted() public {
        vm.expectEmit(false, false, false, true, address(simpleStorage));
        emit DataUpdated(0, 42);
        simpleStorage.set(42);
    }

    function test_RevertWhenNotOwnerCallsSet() public {
        vm.prank(nonOwner);
        vm.expectRevert(SimpleStorage.SimpleStorage__NotOwner.selector);
        simpleStorage.set(42);
    }

    function testFuzz_SetUpdatesValue(uint256 randomValue) public {
        simpleStorage.set(randomValue);
        assertEq(simpleStorage.get(), randomValue);
    }
}
