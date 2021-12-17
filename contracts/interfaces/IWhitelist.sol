// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8 .0;

interface IWhitelist {
  event UpdateWhitelistedAddress(
    address account,
    bool isWhitelisted
  );
}