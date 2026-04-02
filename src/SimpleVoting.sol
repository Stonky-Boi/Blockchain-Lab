// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleVoting {
    struct Candidate {
        string name;
        uint256 voteCount;
    }

    Candidate[] public candidates;
    mapping(address => bool) public hasVoted;

    uint256 public votingDeadline;

    error SimpleVoting__VotingClosed();
    error SimpleVoting__InvalidCandidate();

    constructor(string[] memory candidateNames, uint256 durationInMinutes) {
        for (uint256 i = 0; i < candidateNames.length; i++) {
            candidates.push(Candidate({name: candidateNames[i], voteCount: 0}));
        }
        votingDeadline = block.timestamp + (durationInMinutes * 1 minutes);
    }

    function vote(uint256 candidateIndex) public {
        require(!hasVoted[msg.sender], "Already voted");
        if (block.timestamp > votingDeadline) {
            revert SimpleVoting__VotingClosed();
        }
        if (candidateIndex >= candidates.length) {
            revert SimpleVoting__InvalidCandidate();
        }
        hasVoted[msg.sender] = true;
        candidates[candidateIndex].voteCount += 1;
    }

    function getVoteCount(uint256 candidateIndex) public view returns (uint256) {
        if (candidateIndex >= candidates.length) {
            revert SimpleVoting__InvalidCandidate();
        }
        return candidates[candidateIndex].voteCount;
    }

    function getWinner() public view returns (string memory) {
        uint256 winningVoteCount = 0;
        uint256 winningIndex = 0;
        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                winningIndex = i;
            }
        }
        if (candidates.length == 0) {
            return "";
        }
        return candidates[winningIndex].name;
    }
}
