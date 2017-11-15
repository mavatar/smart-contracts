pragma solidity ^0.4.13;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';

contract MCartToken is StandardToken {
  string public name = 'MCartToken';
  string public symbol = 'mCart';
  uint public decimals = 2;
  uint public INITIAL_SUPPLY = 100000000 * 10**decimals;

  function MCartToken() public {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }
}
