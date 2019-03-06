pragma solidity 0.4.19;

import "./ConsortiumToken.sol";
import "./ConsortiumWhitelist.sol";
import "./zeppelin-solidity/contracts/crowdsale/CappedCrowdsale.sol";


contract ConsortiumCrowdsale is CappedCrowdsale, Ownable/*, ConsortiumWhitelist*/ {
    using SafeMath for uint256;
    // Sale status
    enum Stages {
        PreSale,
        Sale,
        SaleOver
    }
    Stages public stage = Stages.PreSale;
    bool public isFinalized = false;
    
    address public whiteListContract;
    
    event Finalized();
    event WhitelistParticipant(address indexed investor);
    event CapUpdated(uint256 cap, uint256 newCap);
    event StageUpdated(uint8 stage, uint8 newStage);

    // Check the stage to be the specified once
    modifier atStage(Stages _stage) {
        require(stage == _stage);
        _;
    }

    // Performs stage transition
    // this modifier first, otherwise the guards
    // will not take the new stage into account.
    modifier transitionGuard() {
        transition();
        _;
        transition();
    }

    // Constructor
    // _owner = (TBD)
    // _wallet = (TBD)
    // _wallet = (TBD)
    // _cap = (TBD)
    function ConsortiumCrowdsale(
        address _owner,
        address _wallet, 
        uint256 _cap
    )
        public
        Crowdsale(
            now,
            now + (24 hours * 3),
            10, // rate
            _wallet // wallet
        )
        CappedCrowdsale(_cap)
    {
        require(_owner != 0x0);
        owner = _owner;
    }

    /************ Public functionality ************/

    // Invest function
    function buyTokens(address beneficiary)
        public
        payable
        transitionGuard
        atStage(Stages.Sale)
    {
        require(validInvestment());

        super.buyTokens(beneficiary);
    }

    // Properly finalize crowdsale
    function finalize()
        public
        transitionGuard
        atStage(Stages.SaleOver)
    {
        require(!isFinalized);

        isFinalized = true;
        uint256 tokensDistributed = token.totalSupply();
        require(tokensDistributed > 0);
        token.finishMinting();
        Finalized();
    }

    /************ Owner functionality ************/
    // Update end time
    function updateEndTime(uint256 newEndTime)
        public
        onlyOwner
        transitionGuard
        atStage(Stages.PreSale)
    {
        require(newEndTime > startTime);
        endTime = newEndTime;
    }

    /************ Internal functionality ************/
    // Make the stage transition if the case
    function transition() internal {
        // If it's time to start the sale
        if (stage == Stages.PreSale && now > startTime) {
            nextStage();
        }

        // If sale running and either cap or endTime is reached
        if (stage == Stages.Sale && super.hasEnded()) {
            nextStage();
        }
    }

    // Creates the token to be sold.
    function createTokenContract() internal returns (MintableToken) {
        whiteListContract = new ConsortiumWhitelist();
        return new ConsortiumToken(whiteListContract);
    }

    // Validate investment
    function validInvestment() internal view returns (bool) {
        bool validAmount = false;
        validAmount = msg.value >= 10 wei && msg.value <= 1 ether;
        return validAmount;
    }

    // Get token amount to transfer
    function getTokenAmount(uint256 weiAmount) internal view returns (uint256) {
        return weiAmount * rate;
    }

    // Transit to the next stage
    function nextStage() internal {
        uint8 oldStage = uint8(stage);
        uint8 newStage = oldStage + 1;

        stage = Stages(newStage);

        StageUpdated(oldStage, newStage);
    }
}
