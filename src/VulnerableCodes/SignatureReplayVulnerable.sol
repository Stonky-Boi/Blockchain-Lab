// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SignatureReplayVulnerable {
    mapping(address => uint256) public balances;

    function permit(address owner, address spender, uint256 amount, uint8 v, bytes32 r, bytes32 s) external {
        // Replayable: no nonce, no chainId, no domain separator
        bytes32 hash = keccak256(abi.encodePacked(owner, spender, amount));
        address signer = ecrecover(hash, v, r, s);
        require(signer == owner, "Invalid signature");
        balances[spender] += amount; // can be replayed
    }
}
