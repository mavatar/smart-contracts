var MCartToken = artifacts.require("MCartToken");
var CampaignContract = artifacts.require("CampaignContract");

module.exports = function(deployer, network, accounts) {
  let now = Math.round((new Date()).getTime() / 1000);

  deployer.deploy(MCartToken).then(function() {
    return deployer.deploy(
      CampaignContract,
      MCartToken.address,
      now,
      now + 31557600, // 1 year
      10, // reward to value ration: 0.10
      60, // influencer reward: 60%
      30, // shopper reward 30%
      10, // oracle reward 10%
      0x0, // any oracle
      // {
      //   gas: 6000000
      // }
    );
  }).then(function() {
    return MCartToken.deployed();
  }).then(function(token) {
    token.approve(CampaignContract.address, 1000000, { from: accounts[0] });
  });
};
