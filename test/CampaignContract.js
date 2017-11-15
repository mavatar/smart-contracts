var MCartToken = artifacts.require("MCartToken");
var CampaignContract = artifacts.require("CampaignContract");

contract('CampaignContract', function(accounts) {
  it("should have a 0 remaining balance", function() {
    var token;
    var campaign;

    return MCartToken.deployed().then(function(instance) {
      token = instance;
      return CampaignContract.deployed();
    }).then(function(instance) {
      campaign = instance;
      return token.balanceOf.call(campaign.address);
    }).then(function(balance) {
      assert.equal(balance.valueOf(), 0, "remaining balance wasn't 0");
    });
  });
  it("should accept funds and update remaining budget", function() {
    var token;
    var campaign;

    return MCartToken.deployed().then(function(instance) {
      token = instance;
      return CampaignContract.deployed();
    }).then(function(instance) {
      campaign = instance;
      return campaign.addFunds(1000, {from: accounts[0]});
    }).then(function(result) {
      return token.balanceOf.call(campaign.address);
    }).then(function(balance) {
      assert.equal(balance.valueOf(), 1000, "after accepting funds remaining balance wasn't 1000");
    });
  });
  it("should distribute funds on verify", function() {
    var token;
    var campaign;

    // Get initial balances of influencer, shopper, oracle, and campaign
    var marketer = accounts[0];
    var influencer = accounts[1];
    var shopper = accounts[2];
    var oracle = accounts[3];

    var campaignStartingBalance;
    var campaignEndingBalance;
    var influencerStartingBalance;
    var influencerEndingBalance;
    var shopperStartingBalance;
    var shopperEndingBalance;
    var oracleStartingBalance;
    var oracleEndingBalance;

    return MCartToken.deployed().then(function(instance) {
      token = instance;
      return CampaignContract.deployed();
    }).then(function(instance) {
      campaign = instance;
      return token.balanceOf.call(influencer);
    }).then(function(balance) {
      influencerStartingBalance = balance.toNumber();
      //console.log("influencerStartingBalance = ", influencerStartingBalance);
      return token.balanceOf.call(shopper);
    }).then(function(balance) {
      shopperStartingBalance = balance.toNumber();
      //console.log("shopperStartingBalance = ", shopperStartingBalance);
      return token.balanceOf.call(oracle);
    }).then(function(balance) {
      oracleStartingBalance = balance.toNumber();
      //console.log("oracleStartingBalance = ", oracleStartingBalance);
      return campaign.addFunds(50000, { from: marketer });
    }).then(function(result) {
      return token.balanceOf.call(campaign.address);
    }).then(function(balance) {
      campaignStartingBalance = balance.toNumber();
      //console.log("campaignStartingBalance = " + campaignStartingBalance);
      return campaign.verifyPurchase(influencer, shopper, 10000, { from: oracle });
    }).then(function(result) {
      return token.balanceOf.call(influencer);
    }).then(function(balance) {
      influencerEndingBalance = balance.toNumber();
      // console.log("influencerEndingBalance = ", influencerEndingBalance);
      assert.equal(influencerEndingBalance, influencerStartingBalance + 600, "influencer balance was not updated correctly");
      return token.balanceOf.call(shopper);
    }).then(function(balance) {
      shopperEndingBalance = balance.toNumber();
      // console.log("shopperEndingBalance = ", shopperEndingBalance);
      assert.equal(shopperEndingBalance, shopperStartingBalance + 300, "shopper balance was not updated correctly");
      return token.balanceOf.call(oracle);
    }).then(function(balance) {
      oracleEndingBalance = balance.toNumber();
      // console.log("oracleEndingBalance = ", oracleEndingBalance);
      assert.equal(oracleEndingBalance, oracleStartingBalance + 100, "oracle balance was not updated correctly");
      return token.balanceOf.call(campaign.address);
    }).then(function(balance) {
      campaignEndingBalance = balance.toNumber();
      // console.log("campaignEndingBalance = " + campaignEndingBalance);
      assert.equal(campaignEndingBalance, campaignStartingBalance - 1000, "campaign balance was not updated correctly");
    });
  });
});
