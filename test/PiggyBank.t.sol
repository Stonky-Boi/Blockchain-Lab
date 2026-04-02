// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {PiggyBank} from "../src/PiggyBank.sol";

contract PiggyBankTest is Test {
    PiggyBank public piggyBank;
    address public user = address(0x123);

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    function setUp() public {
        piggyBank = new PiggyBank();
        vm.deal(user, 10 ether);
    }

    function test_DepositUpdatesBalanceAndEmitsEvent() public {
        vm.startPrank(user);
        vm.expectEmit(true, false, false, true, address(piggyBank));
        emit Deposited(user, 1 ether);
        piggyBank.deposit{value: 1 ether}();
        assertEq(piggyBank.balances(user), 1 ether);
        assertEq(address(piggyBank).balance, 1 ether);
        vm.stopPrank();
    }

    function test_WithdrawUpdatesBalanceAndTransfersEther() public {
        vm.startPrank(user);
        piggyBank.deposit{value: 2 ether}();
        vm.expectEmit(true, false, false, true, address(piggyBank));
        emit Withdrawn(user, 1 ether);
        piggyBank.withdraw(1 ether);
        assertEq(piggyBank.balances(user), 1 ether);
        assertEq(user.balance, 9 ether);
        vm.stopPrank();
    }

    function test_RevertWhenWithdrawingMoreThanBalance() public {
        vm.startPrank(user);
        piggyBank.deposit{value: 1 ether}();
        vm.expectRevert(PiggyBank.PiggyBank__InsufficientBalance.selector);
        piggyBank.withdraw(2 ether);
        vm.stopPrank();
    }

    function test_BonusFundsAreLockedUntilTimestamp() public {
        vm.startPrank(user);
        piggyBank.deposit{value: 1 ether}();
        uint256 unlockTime = block.timestamp + 1 hours;
        piggyBank.lockFunds(unlockTime);
        vm.expectRevert(abi.encodeWithSelector(PiggyBank.PiggyBank__FundsLocked.selector, unlockTime));
        piggyBank.withdraw(1 ether);
        vm.warp(unlockTime + 1 seconds);
        piggyBank.withdraw(1 ether);
        assertEq(piggyBank.balances(user), 0);
        vm.stopPrank();
    }
}
