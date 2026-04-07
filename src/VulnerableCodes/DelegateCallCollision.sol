// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Proxy
contract DelegatecallCollisionProxy {
    address public implementation; // slot 0
    // ...

    fallback() external {
        (bool ok,) = implementation.delegatecall(msg.data);
        require(ok);
    }
}

// Logic contract – will overwrite implementation address when init is called
contract DelegatecallCollisionLogic {
    address public owner; // slot 0 – collides with implementation in proxy!

    function init(address _owner) external {
        owner = _owner; // overwrites proxy.implementation!
    }

    function withdraw() external {
        require(msg.sender == owner);
        payable(msg.sender).transfer(address(this).balance);
    }
}
