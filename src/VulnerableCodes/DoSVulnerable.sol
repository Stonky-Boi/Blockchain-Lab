// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DoSVulnerable {
    address[] public bidders;
    mapping(address => uint256) public bids;

    function bid() external payable {
        bidders.push(msg.sender);
        bids[msg.sender] = msg.value;
    }

    function refundAll() external {
        // Gas cost grows with bidders.length; can become uncallable
        for (uint256 i = 0; i < bidders.length; i++) {
            payable(bidders[i]).transfer(bids[bidders[i]]);
        }
    }
}
