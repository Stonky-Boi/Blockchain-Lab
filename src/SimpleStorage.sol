// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleStorage {
    uint256 private storedData;
    address public owner;

    event DataUpdated(uint256 oldValue, uint256 newValue);

    error SimpleStorage__NotOwner();

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    function _onlyOwner() internal view {
        if (msg.sender != owner) {
            revert SimpleStorage__NotOwner();
        }
    }

    constructor() {
        storedData = 0;
        owner = msg.sender;
    }

    function set(uint256 newValue) public onlyOwner {
        uint256 oldValue = storedData;
        storedData = newValue;
        emit DataUpdated(oldValue, newValue);
    }

    function get() public view returns (uint256) {
        return storedData;
    }
}
