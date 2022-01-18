const CrowdFunding = artifacts.require('CrowdFunding')

module.exports = function (deployer) {
  deployer.deploy(CrowdFunding, '1000000000000000000', '60')
}
