// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {SimpleStorage} from "../src/SimpleStorage.sol";

contract SimpleStorageScript is Script {
    SimpleStorage public simple_storage;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        simple_storage = new SimpleStorage();
        vm.stopBroadcast();
    }
}
