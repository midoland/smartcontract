// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8 .0;

interface IMidoTokenSale {
    struct SaleConfig {
        uint64 whitelistTime; // time that the owner & whitelisted addresses can start buying
        uint64 publicTime; // time that other addresses can start buying
        uint64 endTime; // end time for the sale, only the owner can buy the rest of the supply
        uint64 maxSupply; // max supply of tokens for this sale round
    }

    struct SaleRecord {
        uint64 totalSold; // total amount of tokens have been sold
        uint64 totalWhitelistSold; // total amount of tokens that whitelisted addresses have bought
        uint64 totalPublicSold; // total amount of tokens that have sold to public
    }

    struct UserRecord {
        uint64 whitelistBought; // amount of tokens that have bought as a whitelisted address
        uint64 publicBought; // amount of tokens that have bought as a public address
    }
    
    event WhitelistBought(address indexed buyer, uint256 amount, uint256 amountWeiPaid);
    event PublicBought(address indexed buyer, uint256 amount, uint256 amountWeiPaid);
    event WithdrawSaleFunds(address indexed recipient, uint256 amount);
    event withdrawMidoTokenFunds(address indexed recipient, uint256 amount);
    event UpdateSaleEndTime(uint64 endTime);
    event SaleBegins(bool publicSale);
}