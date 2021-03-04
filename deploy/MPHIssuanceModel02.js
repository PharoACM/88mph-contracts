const BigNumber = require('bignumber.js')

module.exports = async ({ web3, getNamedAccounts, deployments, getChainId, artifacts }) => {
  const { deploy, log } = deployments
  const { deployer } = await getNamedAccounts()
  const config = require('../deploy-configs/get-network-config')

  const deployResult = await deploy('MPHIssuanceModel02', {
    from: deployer,
    args: [
      BigNumber(config.devRewardMultiplier).toFixed()
    ]
  })
  if (deployResult.newlyDeployed) {
    log(`MPHIssuanceModel02 deployed at ${deployResult.address}`)
  }
}
module.exports.tags = ['MPHIssuanceModel02']
module.exports.dependencies = []
