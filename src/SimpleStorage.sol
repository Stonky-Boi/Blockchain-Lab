// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleStorage {
    uint256 private storedData;
    address public owner;

    event DataUpdated(uint256 oldValue, uint256 newValue);

    error SimpleStorage__NotOwner();

    modifier only_owner() {
        if (msg.sender != owner) {
            revert SimpleStorage__NotOwner();
        }
        _;
    }

    constructor() {
        storedData = 0;
        owner = msg.sender;
    }

    function set(uint256 new_value) public only_owner {
        uint256 old_value = storedData;
        storedData = new_value;
        emit DataUpdated(old_value, new_value);
    }

    function get() public view returns (uint256) {
        return storedData;
    }
}
