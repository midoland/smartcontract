// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8 .0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MidoToken is ERC20, AccessControl {
    uint256 public constant MAX_SUPPLY = 1000000000 * 10 ** 18; // 1b
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor(address owner) ERC20("Midoland", "MIDO") {
        _setupRole(DEFAULT_ADMIN_ROLE, owner);
    }

    function addMinter(address minter) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _setupRole(MINTER_ROLE, minter);
    }

    function mint(address recipient, uint256 amount) public onlyRole(MINTER_ROLE) {
        require((totalSupply() + amount) <= MAX_SUPPLY, "Mint exceeds max supply");
        super._mint(recipient, amount);
    }
    
}