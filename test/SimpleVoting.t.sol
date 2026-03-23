// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {SimpleVoting} from "../src/SimpleVoting.sol";

contract SimpleVotingTest is Test {
    SimpleVoting public simple_voting;
    address public voter_1 = address(0x1);
    address public voter_2 = address(0x2);
    address public voter_3 = address(0x3);

    function setUp() public {
        string[] memory names = new string[](3);
        names[0] = "Alice";
        names[1] = "Bob";
        names[2] = "Charlie";
        simple_voting = new SimpleVoting(names, 60);
    }

    function test_constructor_initializes_candidates() public view {
        assertEq(simple_voting.getVoteCount(0), 0);
        assertEq(simple_voting.getVoteCount(1), 0);
        assertEq(simple_voting.getVoteCount(2), 0);
    }

    function test_vote_records_successfully() public {
        vm.prank(voter_1);
        simple_voting.vote(1);
        assertEq(simple_voting.getVoteCount(1), 1);
        assertTrue(simple_voting.hasVoted(voter_1));
    }

    function test_revert_when_voting_twice() public {
        vm.startPrank(voter_1);
        simple_voting.vote(1);
        vm.expectRevert("Already voted");
        simple_voting.vote(2);
        vm.stopPrank();
    }

    function test_revert_when_voting_after_deadline() public {
        vm.warp(block.timestamp + 61 minutes);
        vm.prank(voter_1);
        vm.expectRevert(SimpleVoting.SimpleVoting__VotingClosed.selector);
        simple_voting.vote(0);
    }

    function test_revert_when_invalid_candidate() public {
        vm.prank(voter_1);
        vm.expectRevert(SimpleVoting.SimpleVoting__InvalidCandidate.selector);
        simple_voting.vote(5);
    }

    function test_get_winner_returns_correct_name() public {
        vm.prank(voter_1);
        simple_voting.vote(1);
        vm.prank(voter_2);
        simple_voting.vote(1);
        vm.prank(voter_3);
        simple_voting.vote(2);
        assertEq(simple_voting.getWinner(), "Bob");
    }
}
