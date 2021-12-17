// migrations/2_deploy.js
// SPDX-License-Identifier: MIT
const MidoToken = artifacts.require("MidoToken")
const MidoTokenSale = artifacts.require("MidoTokenSale")

const whitelistTime = 1635148468
const publicTime = 1635788468
const endTime = 1635948468
const maxWhitelistSize = 10
const owner = ""
module.exports = async function (deployer) {
    await deployer.deploy(MidoToken, owner)
    var midoToken = await MidoToken.deployed()
    console.log('Mido Token contract address:', midoToken.address)

    //
    // IDO ON BSC STATION, SO WE DONT NEED TO DEPLOY MIDOTOKENSALE CONTRACT
    //

    
    // await deployer.deploy(MidoTokenSale, midoToken.address, whitelistTime, publicTime, endTime, 100000, maxWhitelistSize)
    // var midoTokenSale = await MidoTokenSale.deployed()
    // console.log(midoTokenSale.address)

};