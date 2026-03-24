// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {PiggyBank} from "../src/PiggyBank.sol";

contract PiggyBankTest is Test {
    PiggyBank public piggy_bank;
    address public user = address(0x123);

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    function setUp() public {
        piggy_bank = new PiggyBank();
        vm.deal(user, 10 ether);
    }

    function test_deposit_updates_balance_and_emits_event() public {
        vm.startPrank(user);
        vm.expectEmit(true, false, false, true, address(piggy_bank));
        emit Deposited(user, 1 ether);
        piggy_bank.deposit{value: 1 ether}();
        assertEq(piggy_bank.balances(user), 1 ether);
        assertEq(address(piggy_bank).balance, 1 ether);
        vm.stopPrank();
    }

    function test_withdraw_updates_balance_and_transfers_ether() public {
        vm.startPrank(user);
        piggy_bank.deposit{value: 2 ether}();
        vm.expectEmit(true, false, false, true, address(piggy_bank));
        emit Withdrawn(user, 1 ether);
        piggy_bank.withdraw(1 ether);
        assertEq(piggy_bank.balances(user), 1 ether);
        assertEq(user.balance, 9 ether);
        vm.stopPrank();
    }

    function test_revert_when_withdrawing_more_than_balance() public {
        vm.startPrank(user);
        piggy_bank.deposit{value: 1 ether}();
        vm.expectRevert(PiggyBank.PiggyBank__InsufficientBalance.selector);
        piggy_bank.withdraw(2 ether);
        vm.stopPrank();
    }

    function test_bonus_funds_are_locked_until_timestamp() public {
        vm.startPrank(user);
        piggy_bank.deposit{value: 1 ether}();
        uint256 unlock_time = block.timestamp + 1 hours;
        piggy_bank.lock_funds(unlock_time);
        vm.expectRevert(abi.encodeWithSelector(PiggyBank.PiggyBank__FundsLocked.selector, unlock_time));
        piggy_bank.withdraw(1 ether);
        vm.warp(unlock_time + 1 seconds);
        piggy_bank.withdraw(1 ether);
        assertEq(piggy_bank.balances(user), 0);
        vm.stopPrank();
    }
}
