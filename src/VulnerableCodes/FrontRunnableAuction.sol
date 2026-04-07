// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FrontRunnableAuction {
    address public highestBidder;
    uint256 public highestBid;

    // BUG: bid amount is public; attacker can see pending tx and outbid at last moment
    function bid() external payable {
        require(msg.value > highestBid, "Not high enough");
        // refund previous bidder (could also be front‑run)
        payable(highestBidder).transfer(highestBid);
        highestBidder = msg.sender;
        highestBid = msg.value;
    }
}