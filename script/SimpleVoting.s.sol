// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {SimpleVoting} from "../src/SimpleVoting.sol";

contract SimpleVotingScript is Script {
    SimpleVoting public simple_voting;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        string[] memory candidate_names = new string[](2);
        candidate_names[0] = "Alice";
        candidate_names[1] = "Bob";
        simple_voting = new SimpleVoting(candidate_names, 1440);
        vm.stopBroadcast();
    }
}
