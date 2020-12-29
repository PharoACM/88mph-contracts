const BigNumber = require('bignumber.js')

module.exports = async ({ web3, getNamedAccounts, deployments, getChainId, artifacts }) => {
  const { deploy, log } = deployments
  const { deployer } = await getNamedAccounts()
  const config = require('../deploy-configs/get-network-config')

  const deployResult = await deploy('TransferrableVesting', {
    from: deployer,
    args: [
      config.mph
    ]
  })
  if (deployResult.newlyDeployed) {
    log(`TransferrableVesting deployed at ${deployResult.address}`)

    const TransferrableVesting = artifacts.require('TransferrableVesting')
    const contract = await TransferrableVesting.at(deployResult.address)
    await contract.transferOwnership(config.govTreasury, { from: deployer })
    log(`Transfer TransferrableVesting ownership to ${config.govTreasury}`)
  }
}
module.exports.tags = ['TransferrableVesting']
module.exports.dependencies = []
