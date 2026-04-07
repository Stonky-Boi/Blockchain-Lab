// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UnsafeTypeCasting {
    function transferSmall(uint256 amount) external pure returns (uint8) {
        // uint256 can be >255; downcast to uint8 truncates without revert
        return uint8(amount);  // e.g., 300 becomes 44
    }
}