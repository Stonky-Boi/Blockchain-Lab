// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DenialOfServiceByRevert {
    address public leader;
    uint256 public highestBid;

    function bid() external payable {
        require(msg.value > highestBid, "Bid too low");

        // BUG: if previous leader's receive() reverts, nobody can dethrone them
        payable(leader).transfer(highestBid);
        leader = msg.sender;
        highestBid = msg.value;
    }
}