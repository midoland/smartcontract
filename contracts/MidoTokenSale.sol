// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8 .0;

import {
    Address
} from '@openzeppelin/contracts/utils/Address.sol';

import {
    MidoToken
} from './MidoToken.sol';
import {
    IMidoTokenSale
} from './interfaces/IMidoTokenSale.sol';
import {
    Whitelist
} from './utils/Whitelist.sol';


contract MidoTokenSale is IMidoTokenSale, Whitelist {

    using Address
    for address;

    uint64 public constant CAP_PER_WHITELISTED_ADDRESS = 500;
    uint64 public constant CAP_PER_ADDRESS = 1000;
    uint256 public constant PRIVATE_SALE_PRICE = 5 ** 16; // 0.005 BNB
    uint256 public constant PUBLIC_SALE_PRICE = 10 ** 16; // 0.01 BNB

    bool public publicSale = false;
    MidoToken public immutable midoToken;
    SaleRecord internal _saleRecord;
    SaleConfig internal _saleConfig;
    mapping(address => UserRecord) internal _userRecord;



    constructor(
        MidoToken _midoToken,
        uint64 _whitelistTime,
        uint64 _publicTime,
        uint64 _endTime,
        uint64 _maxSupply,
        uint256 _maxWhitelistSize
    ) Whitelist(_maxWhitelistSize) {
        midoToken = _midoToken;
        _saleConfig = SaleConfig({
            whitelistTime: _whitelistTime,
            publicTime: _publicTime,
            endTime: _endTime,
            maxSupply: _maxSupply
        });
    }

    function withdrawSaleFunds(address payable recipient, uint256 amount) external onlyOwner {
        (bool success, ) = recipient.call {
            value: amount
        }('');
        require(success, 'withdraw funds failed');
        emit WithdrawSaleFunds(recipient, amount);
    }

    function withdrawTokenFunds(address recipient, uint256 amount) external onlyOwner {
        midoToken.transfer(recipient, amount);
        emit withdrawMidoTokenFunds(recipient, amount);
    }

    function startSale(bool _publicSale) external onlyOwner {
        publicSale = _publicSale;
        emit SaleBegins(publicSale);
    }

    /**
     * @dev Buy amount of tokens
     *   There are different caps for different users at different times
     *   The total sold tokens should be capped to maxSupply
     * @param amount amount of token to buy
     */
    function buy(uint64 amount) external payable {
        address buyer = msg.sender;
        // only EOA or the owner can buy, disallow contracts to buy
        require(!buyer.isContract() || buyer == owner(), 'only EOA or owner');
        require(publicSale, "public sale not started");

        _validateAndUpdateWithBuyAmount(buyer, amount);

        midoToken.transfer(msg.sender, amount);
    }


    /**
     * @dev Update sale end time by the owner only
     *  if new sale end time is in the past, the sale round will be halted
     */
    function updateSaleEndTime(uint64 _endTime) external onlyOwner {
        _saleConfig.endTime = _endTime;
        emit UpdateSaleEndTime(_endTime);
    }

    /**
     * @dev Return the config, with times (whitelistTime, publicTime, endTime) and max supply
     */
    function getSaleConfig() external view returns(SaleConfig memory config) {
        config = _saleConfig;
    }

    /**
     * @dev Return the record, with number of tokens have been sold for different groups
     */
    function getSaleRecord() external view returns(SaleRecord memory record) {
        record = _saleRecord;
    }

    /**
     * @dev Return the user record
     */
    function getUserRecord(address user) external view returns(UserRecord memory record) {
        record = _userRecord[user];
    }
    /**
     * @dev Validate if it is valid to buy and update corresponding data
     *  Logics:
     *    1. Can not buy more than maxSupply
     *    2. If the buy time is in whitelist buy time:
     *      - each whitelisted buyer can buy up to CAP_PER_WHITELISTED_ADDRESS tokens with PRIVATE_SALE_PRICE per token
     *    3. If the buy time is in public buy time:
     *      - each buyer can buy up to total of CAP_PER_ADDRESS tokens with PUBLIC_SALE_PRICE per token
     */
    function _validateAndUpdateWithBuyAmount(address buyer, uint64 amount) internal {
        SaleConfig memory config = _saleConfig;

        // ensure total sold doens't exceed max supply
        require(
            _saleRecord.totalSold + amount <= _saleConfig.maxSupply,
            'max supply reached'
        );

        uint256 totalPaid = msg.value;
        uint256 timestamp = _blockTimestamp();


        require(config.whitelistTime <= timestamp, 'not started');
        require(timestamp <= config.endTime, 'already ended');

        if (config.whitelistTime <= timestamp && timestamp < config.publicTime) {
            // only whitelisted can buy at this period
            require(isWhitelistedAddress(buyer), 'only whitelisted buyer');
            // whitelisted address can buy up to CAP_PER_WHITELISTED_ADDRESS token
            require(totalPaid >= amount * PRIVATE_SALE_PRICE, 'invalid paid value');
            require(
                _userRecord[buyer].whitelistBought + amount <= CAP_PER_WHITELISTED_ADDRESS,
                'whitelisted cap reached'
            );
            _saleRecord.totalWhitelistSold += amount;
            _userRecord[buyer].whitelistBought += amount;
            _saleRecord.totalSold += amount;
            emit WhitelistBought(buyer, amount, totalPaid);
            return;
        }

        if (config.publicTime <= timestamp && timestamp < config.endTime) {
            // anyone can buy up to CAP_PER_ADDRESS tokens with price of PUBLIC_SALE_PRICE bnb per token
            // it is applied for total of whitelistBought + publicBought
            require(totalPaid == amount * PUBLIC_SALE_PRICE, 'invalid paid value');
            require(_userRecord[buyer].publicBought + _userRecord[buyer].whitelistBought + amount <= CAP_PER_ADDRESS, 'normal cap reached');
            _saleRecord.totalPublicSold += amount;
            _userRecord[buyer].publicBought += amount;
            _saleRecord.totalSold += amount;
            emit PublicBought(buyer, amount, totalPaid);
        }
    }

    function _blockTimestamp() internal view returns(uint256) {
        return block.timestamp;
    }
}