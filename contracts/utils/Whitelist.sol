// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8 .0;

import {
  Ownable
} from "@openzeppelin/contracts/access/Ownable.sol";
import {
  EnumerableSet
} from '@openzeppelin/contracts/utils/structs/EnumerableSet.sol';
import {
  IWhitelist
} from '../interfaces/IWhitelist.sol';


contract Whitelist is IWhitelist, Ownable {

  using EnumerableSet
  for EnumerableSet.AddressSet;

  // list of whitelisted addresses
  EnumerableSet.AddressSet internal _whitelistGroup;
  // maximum number of addresses in the _whitelistGroup
  uint256 public immutable maxWhitelistSize;

  constructor(uint256 _maxWhitelistSize) {
    maxWhitelistSize = _maxWhitelistSize;
  }

  function updateWhitelistedGroup(
    address[] calldata accounts,
    bool isWhitelisted
  ) external onlyOwner {
    for (uint256 i = 0; i < accounts.length; i++) {
      if (isWhitelisted && _whitelistGroup.add(accounts[i])) {
        emit UpdateWhitelistedAddress(accounts[i], true);
      } else if (!isWhitelisted && _whitelistGroup.remove(accounts[i])) {
        emit UpdateWhitelistedAddress(accounts[i], false);
      }
    }
    if (isWhitelisted) {
      // simplify by checking only in the end, only when adding new accounts
      require(_whitelistGroup.length() <= maxWhitelistSize, 'too many addresses');
    }
  }

  function getWhitelistedGroup() external view returns(address[] memory accounts) {
    uint256 len = getWhitelistedGroupLength();
    accounts = new address[](len);
    for (uint256 i = 0; i < len; i++) {
      accounts[i] = getWhitelistedAddressAt(i);
    }
  }

  function isWhitelistedAddress(address account) public view returns(bool) {
    return _whitelistGroup.contains(account);
  }

  function getWhitelistedGroupLength() public view returns(uint256 length) {
    length = _whitelistGroup.length();
  }
  
  function getWhitelistedAddressAt(uint256 index) public view returns(address account) {
    account = _whitelistGroup.at(index);
  }
}