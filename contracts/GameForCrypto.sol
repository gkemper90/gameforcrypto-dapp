pragma solidity ^0.6.0;

//import "http://github.com/smartcontractkit/chainlink/blob/master/evm-contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/ChainlinkClient.sol";

contract GameForCrypto is ChainlinkClient {

    uint256 creditValue;
    string public creditTokenName;
    
    address private oracle;
    bytes32 private jobId;
    uint256 private fee;

    string public lastStatus;

    address private owner;
    mapping (address => uint) public balances;
    uint public contractBalance;
    
    address payable custodianAcct;
    
    uint256 contestCount;

    mapping (string => uint256) public contestIDs;

    mapping (bytes32 => uint256) public requestContestIndex;
    
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
        string contestID;
    }
    
    Contest[] contests;
    
    AggregatorV3Interface internal priceFeed;

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

    constructor () public {
        //c28c092ad6f045c79bdbd54ebb42ce4d
        setPublicChainlinkToken();
        oracle = 0x2f90A6D021db21e1B2A077c5a37B3C7E75D15b7e;
        jobId = "50fc4215f89443d185b061e5d7af9490";
        fee = 0.1 * 10 ** 18; // 0.1 LINK
        //Token name for future use, use ETH currently.
        
        //console.log('Setting Credit Token: ', _tokenName);
        creditTokenName = "ETH";//_tokenName;

        //Get Price of Token From Chainlink Oracle
        owner = msg.sender;
        
        //Get Eth / USD Price
        priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        
        //Contract Management Wallet
        custodianAcct = 0x1aC2E22fa9BE5162D79e38b421BCBf65D715971e;
        
        //Init
        contestCount = 0;

        
    }

    function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) {
        uint8 i = 0;
        while(i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }

     function bytes32ToAddress(bytes32 data) public returns (address) {
        return address(uint160(uint256(data)));
    }
    

    function addGamerCredits () public payable {
        //Add Gamer To Smart Contract
        //Requires ETH Deposit
        
        // .001 * 10 ** 8 (.001 Eth ~$1.60 per credit at current price)
        
        require(msg.value >= 1000000000000000, "Minimum 1 Credit = .001 Eth or 1000000000000000 WEI");
        
        updateGamerCredits(msg.value, msg.sender);

    }

    function getContestIndex(string memory contestID) public view returns(uint256) {

        return contestIDs[contestID];

    }
    
    function createContest (string memory _game, uint256 _entryFee, uint256 _maxGamers, string memory _gameID) public returns(uint256) {
        
        //Should be the same as the index.. probably a better way to do this
        uint256 nextContestID = contestCount;
        
        //Add Host to Gamers of contest
        address[] memory gamers = new address[](_maxGamers);
        gamers[0] = msg.sender;
        
        uint256 hostBalance = availableCreditsByGamer(msg.sender);
        
        require(_entryFee <= hostBalance, "Not enough credits");
        
        removeGamerCredits(msg.sender, _entryFee);
        
        //Init Contest
        Contest memory contest = Contest(nextContestID, _game, _entryFee, _entryFee, gamers, _maxGamers, 1, custodianAcct, 0, false, _gameID);
        
        //Add To Contests
        contests.push(contest);

        //Add Contest ID
        contestIDs[_gameID] = nextContestID;
        
        //Increment Contest Count
        contestCount += 1;
        
        //Return Contest index
        return nextContestID;
    }
    
    function addGamerToContest (string memory contestID)  public returns(bool){

        uint256 contestIndex = getContestIndex(contestID);
        
        //Get Contest
        Contest memory contest = contests[contestIndex];
        
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
        contests[contestIndex] = contest;
        
        return true;
    }
    
    function getContestStatsIndex (uint256 contestID) public view returns(uint256, string memory, address[] memory, uint256 maxGamers, uint256 currentGamers, address winner, uint256 score, bool isComplete, string memory) {
        //Get Contest
        Contest memory contest = contests[contestID];
        
        return (contest.matchBalance, contest.game, contest.gamers, contest.maxGamers, contest.currentGamers, contest.winner, contest.score, contest.isComplete, contest.contestID);
    }

    function getContestStats (string memory contestID) public view returns(uint256, string memory, address[] memory, uint256 maxGamers, uint256 currentGamers, address winner, uint256 score, bool isComplete, string memory, uint256 entryFee) {
        //Get Contest

        uint256 contestIndex = getContestIndex(contestID);

        Contest memory contest = contests[contestIndex];
        
        return (contest.matchBalance, contest.game, contest.gamers, contest.maxGamers, contest.currentGamers, contest.winner, contest.score, contest.isComplete, contest.contestID, contest.entryFee);
    }

    function requestContestURL(string memory contestID) public returns (string memory) 
    {

        string memory contestAPIURL = string(abi.encodePacked("https://us-central1-gameforcrypto.cloudfunctions.net/getGamingContestStatus?contestID=", contestID));
        
        return contestAPIURL;
    }

    function requestContestStatus(string memory contestID) public returns (bytes32 requestId) 
    {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);

        string memory contestAPIURL = string(abi.encodePacked("https://us-central1-gameforcrypto.cloudfunctions.net/getGamingContestStatus?contestID=", contestID));
        
        // Set the URL to perform the GET request on
        request.add("get", contestAPIURL);
        //request.add("get", contestAPIURL);
        request.add("path", "winner");
        
        // Sends the request
        bytes32 reqID = sendChainlinkRequestTo(oracle, request, fee);

        uint256 contestIndex = getContestIndex(contestID);

        Contest memory contest = contests[contestIndex];

        //Set requestID => contestIndex
        requestContestIndex[reqID] = contestIndex;

        return reqID;


    }

    function fulfill(bytes32 _requestId, bytes32 _status) public recordChainlinkFulfillment(_requestId)
    {
        
        //Get Winning Address
        string memory _winner = bytes32ToString(_status);

        lastStatus = _winner;

        //Contest Index
        uint256 contestIndex = requestContestIndex[_requestId];

        //Get Contest
        Contest memory contest = contests[contestIndex];

        //Ensure winner is not custodian account, if so, revert
        //require(_winner != contest.winner, 'No Valid Winner Yet..');

        //To-Do Ensure winner address is part of contest

        //Set Contest Winner
        //contest.winner = _winner;
        contest.isComplete = true;

        //Transfer Credit Balance To Winner
        //balances[_winner] += contest.matchBalance;
        contest.matchBalance = 0;
        
        //Update Contest
        contests[contestIndex] = contest;

        //To-Do Emit Contest Complete Event

    }

    function getLastStatus () public view returns(string memory) {
        return lastStatus;
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

    function withdrawlGamerCredits  (uint256 amount) public {
        //Withdrawl Credits To Gamer
        //Called By wallet owner only (at the moment)

        uint256 maxAllowed = balances[msg.sender];

        require(amount <= maxAllowed, "Requested More Credits Than Balance Available");
        
        //Convert credits to WEI
        uint256 toTransfer = amount * 1000000000000000;
        balances[msg.sender] -= amount;
        
        msg.sender.transfer(toTransfer);
    }

    function withdrawlAllGamerCredits  () public {
        //Withdrawl Credits To Gamer
        //Called By wallet owner only (at the moment)

        uint256 amount = balances[msg.sender];

        //Convert credits to WEI
        uint256 toTransfer = amount * 1000000000000000;
        balances[msg.sender] -= amount;
        
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
    

}