// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {SimpleVoting} from "../src/SimpleVoting.sol";

contract SimpleVotingScript is Script {
    SimpleVoting public simpleVoting;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        string[] memory candidateNames = new string[](2);
        candidateNames[0] = "Alice";
        candidateNames[1] = "Bob";
        simpleVoting = new SimpleVoting(candidateNames, 1440);
        vm.stopBroadcast();
    }
}
