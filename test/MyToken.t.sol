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

    function test_InitialSupplyAssignedToOwner() public view {
        assertEq(token.balanceOf(owner), 1000 * 10 ** 18);
        assertEq(token.totalSupply(), 1000 * 10 ** 18);
    }

    function test_TransferUpdatesBalancesAndEmitsEvent() public {
        uint256 transferAmount = 100 * 10 ** 18;
        vm.expectEmit(true, true, false, true, address(token));
        emit Transfer(owner, alice, transferAmount);
        assertTrue(token.transfer(alice, transferAmount));
        assertEq(token.balanceOf(alice), transferAmount);
        assertEq(token.balanceOf(owner), 900 * 10 ** 18);
    }

    function test_ApproveSetsAllowanceAndEmitsEvent() public {
        uint256 approvalAmount = 50 * 10 ** 18;
        vm.expectEmit(true, true, false, true, address(token));
        emit Approval(owner, alice, approvalAmount);
        assertTrue(token.approve(alice, approvalAmount));
        assertEq(token.allowance(owner, alice), approvalAmount);
    }

    function test_TransferFromWorksWithAllowance() public {
        uint256 approvalAmount = 50 * 10 ** 18;
        token.approve(alice, approvalAmount);
        vm.prank(alice);
        assertTrue(token.transferFrom(owner, bob, approvalAmount));
        assertEq(token.balanceOf(bob), approvalAmount);
        assertEq(token.allowance(owner, alice), 0);
    }

    function test_RevertTransferFromExceedsAllowance() public {
        token.approve(alice, 10 * 10 ** 18);
        vm.prank(alice);
        vm.expectRevert(MyToken.MyToken__InsufficientAllowance.selector);
        token.transferFrom(owner, bob, 20 * 10 ** 18);
    }

    function test_BonusMintIncreasesSupply() public {
        token.mint(alice, 500 * 10 ** 18);
        assertEq(token.balanceOf(alice), 500 * 10 ** 18);
        assertEq(token.totalSupply(), 1500 * 10 ** 18);
    }

    function test_RevertBonusMintNotOwner() public {
        vm.prank(alice);
        vm.expectRevert(MyToken.MyToken__NotOwner.selector);
        token.mint(bob, 100 * 10 ** 18);
    }
}
