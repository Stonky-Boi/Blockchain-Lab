// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {SimpleVoting} from "../src/SimpleVoting.sol";

contract SimpleVotingTest is Test {
    SimpleVoting public simpleVoting;
    address public voter1 = address(0x1);
    address public voter2 = address(0x2);
    address public voter3 = address(0x3);

    function setUp() public {
        string[] memory names = new string[](3);
        names[0] = "Alice";
        names[1] = "Bob";
        names[2] = "Charlie";
        simpleVoting = new SimpleVoting(names, 60);
    }

    function test_ConstructorInitializesCandidates() public view {
        assertEq(simpleVoting.getVoteCount(0), 0);
        assertEq(simpleVoting.getVoteCount(1), 0);
        assertEq(simpleVoting.getVoteCount(2), 0);
    }

    function test_VoteRecordsSuccessfully() public {
        vm.prank(voter1);
        simpleVoting.vote(1);
        assertEq(simpleVoting.getVoteCount(1), 1);
        assertTrue(simpleVoting.hasVoted(voter1));
    }

    function test_RevertWhenVotingTwice() public {
        vm.startPrank(voter1);
        simpleVoting.vote(1);
        vm.expectRevert("Already voted");
        simpleVoting.vote(2);
        vm.stopPrank();
    }

    function test_RevertWhenVotingAfterDeadline() public {
        vm.warp(block.timestamp + 61 minutes);
        vm.prank(voter1);
        vm.expectRevert(SimpleVoting.SimpleVoting__VotingClosed.selector);
        simpleVoting.vote(0);
    }

    function test_RevertWhenInvalidCandidate() public {
        vm.prank(voter1);
        vm.expectRevert(SimpleVoting.SimpleVoting__InvalidCandidate.selector);
        simpleVoting.vote(5);
    }

    function test_GetWinnerReturnsCorrectName() public {
        vm.prank(voter1);
        simpleVoting.vote(1);
        vm.prank(voter2);
        simpleVoting.vote(1);
        vm.prank(voter3);
        simpleVoting.vote(2);
        assertEq(simpleVoting.getWinner(), "Bob");
    }
}
