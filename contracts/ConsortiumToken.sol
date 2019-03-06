pragma solidity 0.4.19;

import "./ConsortiumWhitelist.sol";
import "./zeppelin-solidity/contracts/token/ERC20/MintableToken.sol";
import "./zeppelin-solidity/contracts/token/ERC20/BurnableToken.sol";

contract ConsortiumToken is MintableToken, BurnableToken/*, ConsortiumWhitelist*/ {
    string public name = "Consortium Token";
    string public symbol = "CONT";
    uint8 public decimals = 1;

    address public whitelistContract;
    
    modifier onlyWhitelisted(address _beneficiary) {
        require(seeIfWhitelisted(_beneficiary) == true);
        _;
    }    
    
    // Constructor
    function ConsortiumToken(address _whitelistContract) public {
        whitelistContract = _whitelistContract;
    }
    
    function seeIfWhitelisted(address _beneficiary) public view returns (bool) {
        return ConsortiumWhitelist(whitelistContract).checkWhitelisted(_beneficiary);
    }

    /**
    * Transfer only to participants that are member of the white list
    */
    function transfer(address _to, uint256 _value) public onlyWhitelisted(_to) returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * Gets the balance of the specified whitelisted address.
    */
    function balanceOf(address _owner) public view onlyWhitelisted(_owner) returns (uint256 balance) {
        return balances[_owner];
    }

}
