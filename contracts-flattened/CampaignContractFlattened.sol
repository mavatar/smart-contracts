pragma solidity ^0.4.13;

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

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

contract Token {
  /**
   * @dev Transfer tokens from one address to another
   * @param from address The address which you want to send tokens from
   * @param to address The address which you want to transfer to
   * @param value uint256 the amount of tokens to be transfered
   */
  function transferFrom(address from, address to, uint256 value) public;

  /**
  * @dev transfer token for a specified address
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function transfer(address to, uint256 value) public;
}

