// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";

contract MyTokenBonus is ERC20, Ownable {
    constructor(uint256 initial_supply) ERC20("MyToken", "MTK") Ownable(msg.sender) {
        _mint(msg.sender, initial_supply);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
