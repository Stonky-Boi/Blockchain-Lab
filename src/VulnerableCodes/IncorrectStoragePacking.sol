// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// This contract expects `a` to be 0, but `b` can be set to a value that spills
contract IncorrectStoragePacking {
    uint128 public a;   // slot 0, first 16 bytes
    uint128 public b;   // slot 0, last 16 bytes – both in same slot

    function setB(uint128 _b) external {
        b = _b;          // writing b does not affect a – correct
    }

    // But if we had a function that writes a full 32-byte value to slot 0,
    // it could overwrite both a and b unintentionally.
    function unsafeWrite(uint256 value) external {
        assembly {
            sstore(0, value)   // overwrites both a and b
        }
    }
}