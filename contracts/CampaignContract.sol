pragma solidity ^0.4.13;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import './interfaces/Token.sol';

contract CampaignContract is Ownable {
  using SafeMath for uint256;

  uint256 constant public decimals = 2;
  uint256 constant private denominator = 10**decimals;

  string constant public VERSION = "0.1.0";

  address MCART_TOKEN_CONTRACT;

  uint256 public startTime;
  uint256 public endTime;

  uint256 public totalBudget = 0;
  uint256 public rewardToValue;

  uint256 public influencerShare;
  uint256 public shopperShare;
  uint256 public oracleShare;
  address public oracle;

  // event LogAddFunds(address indexed owner, uint256 added, uint256 total, uint256 remaining);

  function CampaignContract (
    address _mCartToken,
    uint256 _startTime,
    uint256 _endTime,
    uint256 _rewardToValue,
    uint256 _influencerShare,
    uint256 _shopperShare,
    uint256 _oracleShare,
    address _oracle
  ) public {
    //require(_startTime >= now);
    require(_endTime >= _startTime);

    uint256 sum = _influencerShare.add(_shopperShare).add(_oracleShare);
    assert(sum <= denominator);

    MCART_TOKEN_CONTRACT = _mCartToken;

    startTime = _startTime;
    endTime = _endTime;

    rewardToValue = _rewardToValue;

    influencerShare = _influencerShare;
    shopperShare = _shopperShare;
    oracleShare = _oracleShare;

    oracle = _oracle;
  }

  modifier onlyOracle() {
    require(oracle == 0x0 || msg.sender == oracle);
    _;
  }

  function addFunds(uint256 value) public onlyOwner {
    totalBudget = totalBudget.add(value);
    mCartTokenTransferFrom(msg.sender, this, value);
    // LogAddFunds(msg.sender, value, totalBudget, remainingBudget);
  }

  function removeFunds(uint256 value) public onlyOwner {
    totalBudget = totalBudget.sub(value);
    mCartTokenTransfer(msg.sender, value);
  }

  function verifyPurchase(address influencer, address shopper, uint256 value) public onlyOracle returns (uint256) {
    require(now < endTime);

    uint256 reward = value.mul(rewardToValue).div(denominator);
    require(reward > 0);

    uint256 influencerReward = reward.mul(influencerShare).div(denominator);
    uint256 shopperReward = reward.mul(shopperShare).div(denominator);
    uint256 oracleReward = reward.mul(oracleShare).div(denominator);

    uint256 actualReward = influencerReward.add(shopperReward).add(oracleReward);

    if (influencerReward > 0) {
      mCartTokenTransfer(influencer, influencerReward);
    }

    if (shopperReward > 0) {
      mCartTokenTransfer(shopper, shopperReward);
    }

    if (oracleReward > 0) {
      mCartTokenTransfer(msg.sender, oracleReward);
    }

    return actualReward;
  }

  function mCartTokenTransferFrom(address _from, address _to, uint256 _value) internal {
    Token(MCART_TOKEN_CONTRACT).transferFrom(_from, _to, _value);
  }

  function mCartTokenTransfer(address _to, uint256 _value) internal {
    Token(MCART_TOKEN_CONTRACT).transfer(_to, _value);
  }
}
