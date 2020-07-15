usePlugin('@nomiclabs/buidler-ganache')
usePlugin('@nomiclabs/buidler-truffle5')
usePlugin('solidity-coverage')

let secret

try {
  secret = require('./secret.json')
} catch {
  secret = {
    account: '',
    mnemonic: ''
  }
}

module.exports = {
  solc: {
    version: '0.5.17',
    optimizer: {
      enabled: true,
      runs: 200
    }
  },
  paths: {
    sources: './contracts'
  },
  networks: {
    mainnet: {
      url: 'https://mainnet.infura.io/v3/7a7dd3472294438eab040845d03c215c',
      chainId: 1,
      from: secret.account,
      accounts: {
        mnemonic: secret.mnemonic
      }
    },
    buidlerevm: {
      blockGasLimit: 9950000,
      gas: 'auto',
      gasPrice: 'auto'
    },
    ganache: {
      url: 'http://localhost:8545',
      fork: 'https://mainnet.infura.io/v3/2f4ac5ce683c4da09f88b2b564d44199',
      unlockedAccounts: ['0x9eb7f2591ed42dee9315b6e2aaf21ba85ea69f8c'],
      gasLimit: 1e7
    }
  }
}
