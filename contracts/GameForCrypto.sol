pragma solidity ^0.7.0;

//import "http://github.com/smartcontractkit/chainlink/blob/master/evm-contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
//import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract GameForCrypto {

    uint256 creditValue;
    string public creditTokenName;
    enum State { Waiting, Ready, Active }

    address private owner;
    mapping (address => uint) public balances;
    uint public contractBalance;
    
    address payable custodianAcct;
    
    uint256 contestCount;
    
    struct Contest {
        uint id;
        string game;
        uint256 matchBalance;
        uint256 entryFee;
        address[] gamers;
        uint256 maxGamers;
        uint256 currentGamers;
        address winner;
        uint256 score;
        bool isComplete;
    }
    
    Contest[] contests;
    
    //AggregatorV3Interface internal priceFeed;

    /**
     * Network: Kovan
     * Aggregator: ETH/USD
     * Address: 0x9326BFA02ADD2366b30bacB125260Af641031331
     * 
     * 
     * Rinkeby
     * Address: 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
     */
     
     //event Sent(address from, address to, uint amount);

    constructor (string memory _tokenName)  {
        //Token name for future use, use ETH currently.
        
        //console.log('Setting Credit Token: ', _tokenName);
        creditTokenName = _tokenName;

        //Get Price of Token From Chainlink Oracle
        owner = msg.sender;
        
        //Get Eth / USD Price
        //priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        
        //Contract Management Wallet
        custodianAcct = 0x1aC2E22fa9BE5162D79e38b421BCBf65D715971e;
        
        //Init
        contestCount = 0;
    }

    function addGamerCredits () public payable {
        //Add Gamer To Smart Contract
        //Requires ETH Deposit
        
        // .001 * 10 ** 8 (.001 Eth ~$1.60 per credit at current price)
        
        require(msg.value >= 1000000000000000, "Minimum 1 Credit = .001 Eth or 1000000000000000 WEI");
        
        updateGamerCredits(msg.value, msg.sender);

    }
    
    function createContest (string memory _game, uint256 _entryFee, uint256 _maxGamers) public returns(uint256) {
        
        //Should be the same as the index.. probably a better way to do this
        uint nextContestID = contestCount;
        
        //Add Host to Gamers of contest
        address[] memory gamers = new address[](_maxGamers);
        gamers[0] = msg.sender;
        
        uint256 hostBalance = availableCreditsByGamer(msg.sender);
        
        require(_entryFee <= hostBalance, "Not enough credits");
        
        removeGamerCredits(msg.sender, _entryFee);
        
        //Init Contest
        Contest memory contest = Contest(nextContestID, _game, _entryFee, _entryFee, gamers, _maxGamers, 1, custodianAcct, 0, false);
        
        //Add To Contests
        contests.push(contest);
        
        //Increment Contest Count
        contestCount += 1;
        
        //Return Contest index
        return nextContestID;
    }
    
    function addGamerToContest (uint256 contestID)  public returns(bool){
        
        //Get Contest
        Contest memory contest = contests[contestID];
        
        //Contest Max gamers
        uint256 maxGamers = contest.maxGamers;
        uint256 currentGamers = contest.currentGamers;
        
        uint256 availableSpots = maxGamers - currentGamers;
        
        require(availableSpots > 0, "Contest Already Filled");
        
        //Add sender to contest
        contest.gamers[currentGamers] = msg.sender;
        
        uint256 gamerBalance = availableCreditsByGamer(msg.sender);
        
        require(contest.entryFee <= gamerBalance, "Not enough credits");
        
        removeGamerCredits(msg.sender, contest.entryFee);
        
        //Increase balance
        contest.matchBalance += contest.entryFee;
        
        //Increase currentGamers
        contest.currentGamers += 1;
        
        //Update Contest
        contests[contestID] = contest;
        
        return true;
    }
    
    function getContestStats (uint256 contestID) public view returns(uint256, string memory, address[] memory, uint256 maxGamers, uint256 currentGamers, address winner, uint256 score, bool isComplete) {
        //Get Contest
        Contest memory contest = contests[contestID];
        
        return (contest.matchBalance, contest.game, contest.gamers, contest.maxGamers, contest.currentGamers, contest.winner, contest.score, contest.isComplete);
    }
    
    function getContestCount () public view returns(uint) {
        return contestCount;
    }
    
    function custodianAcctBalance () public view returns(uint256){
        //Maybe should be named Smart Contract Balance...
        return address(this).balance;
    }
    
    function memberAcctBalance () public view returns(uint256){
        //View Member Balance in Credits
        return balances[msg.sender];
    }
    
    function acctBalance (address gamerAddress) public view returns(uint256){
        //View Member Balance (By Address) in Credits
        return balances[gamerAddress];
    }
    
    function availableCreditsByGamer (address _gamer) public view returns(uint256){
        
        return balances[_gamer];
    }

    function updateGamerCredits (uint256 amount, address gamerAddress) internal {
        //Convert Deposit To Credits Balance
        //Save Balance On Blockchain
        
        uint256 credits = amount / 1000000000000000;
        balances[gamerAddress] += credits;

    }

    function removeGamerCredits (address gamerAddress, uint256 amount) public {
        //Adjust Gamer Credit Balance
        balances[gamerAddress] -= amount;
    }

    function removeGamer () public {
        //Remove Gamer From Smart Contract
        //For future use.
    }

    function withdrawlGamerCredits  () public {
        //Withdrawl Credits To Gamer
        //Called By wallet owner only (at the moment)
        
        //Convert credits to WEI
        uint256 toTransfer = balances[msg.sender] * 1000000000000000;
        
        msg.sender.transfer(toTransfer);
    }

    function transferGamerCredits  () public {
        //Transfer Credits From Pool To Gamer
        //For future use (credit account from pool)
    }
    
    function declareContestWinner (uint256 contestID, address contestWinner) public {
        
        //Get Contest
        Contest memory contest = contests[contestID];
        
        //To-Do check for address part of contest.
        
        //Set Contest Winner
        contest.winner = contestWinner;
        contest.isComplete = true;
        
        //Transfer Credit Balance To Winner
        balances[contestWinner] += contest.matchBalance;
        contest.matchBalance = 0;
        
        //Update Contest
        contests[contestID] = contest;
        
    }
    
    function getOwner() public view returns(address) {
        return owner;
    }
    
    /*
    function getEthPrice() public view returns (int) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price;
    }
    */

}