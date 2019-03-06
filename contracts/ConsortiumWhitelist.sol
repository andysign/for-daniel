pragma solidity 0.4.19;

contract ConsortiumWhitelist {
    
    // Whitelisted participants
    mapping (address => bool) public whitelist;

    // Whitelist modifier
    modifier onlyWhitelisted() {
        require(whitelist[msg.sender] == true);
        _;
    }    

    // Insert another participant
    function insertWhitelist(address _beneficiary) public onlyWhitelisted {
        whitelist[_beneficiary] = true;
    }
    
    // Remove but can't remove self
    function removeWhitelist(address _beneficiary) public onlyWhitelisted {
        require(_beneficiary != msg.sender);
        whitelist[_beneficiary] = false;
    }

    // Constructor
    function ConsortiumWhitelist() public {
        whitelist[tx.origin] = true;
    }
    
    // Getter function
    function checkWhitelisted(address _beneficiary) public view returns (bool) {
        return whitelist[_beneficiary];
    }
        
}