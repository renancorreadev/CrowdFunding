const { assert } = require('chai')
const CrowdFunding = artifacts.require('CrowdFunding')
require('chai').use(require('chai-as-promised')).should()

contract('CrowdFunding', (accounts) => {
  before(async () => {
    crowdFunding = await CrowdFunding.new()
  })

  describe('', async () => {
    it('should the name off contract', async (done) => {
      const contract = crowdFunding.address
      assert.isOk('Sucess')
      done()
    })
  })
})
