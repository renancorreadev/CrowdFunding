const { assert, expect } = require('chai')
const CrowdFunding = artifacts.require('CrowdFunding')
require('chai').use(require('chai-as-promised')).should()

contract('CrowdFunding', (accounts) => {
  before(async () => {
    crowdFunding = await CrowdFunding.new('1000000000000000000', '60')
  })

  describe('Test - Contract Deployment.', () => {
    it('should the name off contract', async () => {
      const contract = await crowdFunding.address
      assert.isOk(contract, 'Sucess')
    })
  })

  describe('Test - Contribuite function.', () => {
    it('should the contribuite ether to contract', async () => {
      const tx = await crowdFunding.contribuite({
        from: accounts[1],
        value: '140',
      })
      assert.isOk(tx, 'Sucess')
    })
  })

  describe('Test - Resgarding Funds.', () => {
    it('should the Recover ether to contract', async () => {
      setTimeout(async () => {
        await crowdFunding
          .getRefunds({ from: accounts[1] })
          .then(function (result) {
            expect(result).to.throw('A error encountered in status.')
          })
      }, 4000)
    })
  })

  describe('Test - Change Goal', () => {
    it('should the change Goal ', async () => {
      const tx = await crowdFunding.changeGoal('200', { from: accounts[0] })
      assert.isOk(tx, 'Sucess')
    })
  })

  describe('Test - Start new CrowdFund', () => {
    it('should the change Goal ', async () => {
      const time = await crowdFunding.deadline()
      setTimeout(async function () {
        await crowdFunding
          .StartNewCrowFunding('100', '1000', '30', { from: accounts[0] })
          .then(function (result) {
            expect(result).to.throw('A error encountered in status.')
          })
      }, time)
    })
  })
})
