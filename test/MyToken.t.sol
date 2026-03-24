// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {MyToken} from "../src/MyToken.sol";

contract MyTokenTest is Test {
    MyToken public token;
    address public owner = address(this);
    address public alice = address(0x1);
    address public bob = address(0x2);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function setUp() public {
        token = new MyToken(1000 * 10 ** 18);
    }

    function test_initial_supply_assigned_to_owner() public view {
        assertEq(token.balanceOf(owner), 1000 * 10 ** 18);
        assertEq(token.totalSupply(), 1000 * 10 ** 18);
    }

    function test_transfer_updates_balances_and_emits_event() public {
        uint256 transfer_amount = 100 * 10 ** 18;
        vm.expectEmit(true, true, false, true, address(token));
        emit Transfer(owner, alice, transfer_amount);
        assertTrue(token.transfer(alice, transfer_amount));
        assertEq(token.balanceOf(alice), transfer_amount);
        assertEq(token.balanceOf(owner), 900 * 10 ** 18);
    }

    function test_approve_sets_allowance_and_emits_event() public {
        uint256 approval_amount = 50 * 10 ** 18;
        vm.expectEmit(true, true, false, true, address(token));
        emit Approval(owner, alice, approval_amount);
        assertTrue(token.approve(alice, approval_amount));
        assertEq(token.allowance(owner, alice), approval_amount);
    }

    function test_transfer_from_works_with_allowance() public {
        uint256 approval_amount = 50 * 10 ** 18;
        token.approve(alice, approval_amount);
        vm.prank(alice);
        assertTrue(token.transferFrom(owner, bob, approval_amount));
        assertEq(token.balanceOf(bob), approval_amount);
        assertEq(token.allowance(owner, alice), 0);
    }

    function test_revert_transfer_from_exceeds_allowance() public {
        token.approve(alice, 10 * 10 ** 18);
        vm.prank(alice);
        vm.expectRevert(MyToken.MyToken__InsufficientAllowance.selector);
        token.transferFrom(owner, bob, 20 * 10 ** 18);
    }

    function test_bonus_mint_increases_supply() public {
        token.mint(alice, 500 * 10 ** 18);
        assertEq(token.balanceOf(alice), 500 * 10 ** 18);
        assertEq(token.totalSupply(), 1500 * 10 ** 18);
    }

    function test_revert_bonus_mint_not_owner() public {
        vm.prank(alice);
        vm.expectRevert(MyToken.MyToken__NotOwner.selector);
        token.mint(bob, 100 * 10 ** 18);
    }
}
