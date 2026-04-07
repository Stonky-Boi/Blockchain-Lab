// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BlockhashDependence {
    function pickWinner(address[] memory players) external view returns (address) {
        // BUG: blockhash only available for last 256 blocks; also manipulable by miner
        uint256 rand = uint256(blockhash(block.number - 1)) % players.length;
        return players[rand];
    }
}