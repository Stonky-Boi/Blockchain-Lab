// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UninitializedProxy {
    address public implementation;
    address public owner; // storage collision risk

    constructor(address _impl) {
        implementation = _impl;
    }

    // BUG: no check that initialize can be called only once
    function initialize(address _owner) external {
        owner = _owner;
    }

    fallback() external {
        (bool ok,) = implementation.delegatecall(msg.data);
        require(ok);
    }
}
