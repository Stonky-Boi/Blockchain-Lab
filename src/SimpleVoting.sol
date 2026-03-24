// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleVoting {
    struct Candidate {
        string name;
        uint256 voteCount;
    }

    Candidate[] public candidates;
    mapping(address => bool) public hasVoted;

    uint256 public voting_deadline;

    error SimpleVoting__VotingClosed();
    error SimpleVoting__InvalidCandidate();

    constructor(string[] memory candidate_names, uint256 duration_in_minutes) {
        for (uint256 i = 0; i < candidate_names.length; i++) {
            candidates.push(Candidate({name: candidate_names[i], voteCount: 0}));
        }
        voting_deadline = block.timestamp + (duration_in_minutes * 1 minutes);
    }

    function vote(uint256 candidate_index) public {
        require(!hasVoted[msg.sender], "Already voted");
        if (block.timestamp > voting_deadline) {
            revert SimpleVoting__VotingClosed();
        }
        if (candidate_index >= candidates.length) {
            revert SimpleVoting__InvalidCandidate();
        }
        hasVoted[msg.sender] = true;
        candidates[candidate_index].voteCount += 1;
    }

    function getVoteCount(uint256 candidate_index) public view returns (uint256) {
        if (candidate_index >= candidates.length) {
            revert SimpleVoting__InvalidCandidate();
        }
        return candidates[candidate_index].voteCount;
    }

    function getWinner() public view returns (string memory) {
        uint256 winning_vote_count = 0;
        uint256 winning_index = 0;
        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > winning_vote_count) {
                winning_vote_count = candidates[i].voteCount;
                winning_index = i;
            }
        }
        if (candidates.length == 0) {
            return "";
        }
        return candidates[winning_index].name;
    }
}
