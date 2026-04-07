// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DelegatecallToUntrusted {
    address public implementation;

    // Anyone can set the implementation address
    function setImplementation(address _impl) external {
        implementation = _impl;
    }

    function execute(bytes calldata data) external payable {
        // BUG: delegatecall to an address that can be set by anyone
        (bool ok,) = implementation.delegatecall(data);
        require(ok, "delegatecall failed");
    }
}
