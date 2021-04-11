##Deploying Game For Crypto Smart Contract

Add Kovan Private Key, Infura URI in hardhat.config.js. Run the below in terminal. After contract is deployed, be sure to send it Link.
```npx hardhat run scripts/sample-script.js --network kovan```

- Here is a link to etherscan with the currently deployed contract as of 4/11: 
https://kovan.etherscan.io/address/0xe7aF60280612eb99263f305c0C61D837aa5D1CE2#events

**Events:**
```gamerJoinedContest(string gamerName, string contestID)```
```gamerNameClaimed(string gamerName, address gamerAddress)```
```contestCreated(string contestID, string hostGamer, string game, uint256 maxPlayers)```
```winnerDetermined(string gamerName, string contestID)```

**Important Smart Contract Functions**

- Send ETH along with gamerName to claim gamerName, and add credits to account. Minimum 10 Credits or 10x 100000000000000 WEI
```function addGamerCredits (string memory gamerName) public payable```

- Create Contest - Send gameName, entryFee (in credits, min 10), maxGamers (max players for contest), and the gamerID (unique contestID)
```function createContest (string memory _game, uint256 _entryFee, uint256 _maxGamers, string memory _gameID) public```

- Add Gamer To Contest. Attempts to add the gamer (determined by sender address) to the contest.
```function addGamerToContest (string memory contestID)```

- Get Contest Status. Returns subset of contest struct: matchBalance, game, gamers, maxGamers, currentGamers, winner, score, isComplete, contestID, entryFee
``` function getContestStats (string memory contestID) public view returns(uint256, string memory, address[] memory, uint256 maxGamers, uint256 currentGamers, string memory winner, uint256 score, bool isComplete, string memory, uint256 entryFee)```

- Request status of contest. Send contestID. Send Chainlink API Request to winner.
```function requestContestStatus(string memory contestID) public```

- Fulfill Chainlink contest winner request.
```function fulfill(bytes32 _requestId, bytes32 _status) public recordChainlinkFulfillment(_requestId)```

- Withdraw credits (in ETH) back to gamers wallet. Send amount of credits to withdraw.
```function withdrawlGamerCredits  (uint256 amount) public```

- Returns amount of credits available in the gamers account.
```function availableCreditsByGamer (address _gamer) public view returns(uint256)```
**
Front End Demo: https://gameforcrypto.web.app/
**

##What is Game For Crypto?

Game For Crypto, GFC, is a platform developed to act as an online arcade, where gamers can win cryptocurrency based on gaming challenges.

Contests are created by gamers, and an entry fee is set (in credits). Each gamer who joins the contest must pay the entry fee. These credits are acquired by using the GFC front end, and cost .0001 ETH per credit.

The first gamer to complete the conditions of the contest, or with the highest score at the end of the contest wins!

Credits are stored on the GFC smart contract linked to Ethereum address / Gamer Name. Gamers can withdraw credits at anytime, which is returned as ETH to the gamers ETH wallet.

##What are examples of Gaming Contests?
GFC was developed quickly for the Chainlink Hackathon. It currently only has support for 2 games, Snake and Fortnite.

Current contest win conditions include:

Snake: High score after 3 rounds.
Fortnite: First to get 10 eliminations or First to get a Victory Royale.

##How to use Game For Crypto?
Currently, GFC is functional and in testing, deployed on the Kovan Ethereum Testnet.

If you would like to participate, please follow these steps.

1. Ensure metamask is installed as in extension on your browser.
2. Open metamask, and ensure you are on the Kovan network.
3. Click connect on the top right corner of the page, to request access / connect your wallet.
Note: This is your key to using GFC, and the only registration information needed. No email needed.
4. Pick a Gamer Name, 32 Characters or Less. No Spaces.
Optional: If you intend to play Fortnite contests, set your Fortnite name.
5. Choose an amount of credits to deposit. 10 min. Click insert credits.

Now with credits in your account, you can join contests, or even create your own. Win a few contests and withdraw your credits at anytime!

Have fun!

##Who Developed Game For Crypto and Why?
GFC was developed by Geoff Kemper. I am a freelancer who specializes in Node, React, React Native, Firebase, AWS, and other less popular platforms.

**I am very interested in hearing about opportunities to work on projects involving blockchain and smart contracts.**

Through developing GFC, I have acquired a working knowledge of Smart Contracts, Solidity and Web3, along with integration in front end and back end systems.

**I am also very interested in continuing to build out GFC to be production ready at some point.**

If you are interested in helping as a team member or otherwise, please reach out, sincerely, Geoff Kemper. GameForCrypto@gmail.com

Important Note: This demonstration is running on Kovan Testnet only. GFC has no affiliation with Fortnite. All Fortnite data is provided by public APIs.

##What Parts Make Up Game For Crypto?

- Smart Contract: Developed utilizing Solidity, Chainlink API Oracle and Hardhat. The repo you are currently viewing.

- Front End : React Application developed to interface with the Game For Crypto smart contract. Allows  depositing credits. withdrawing credits, creating contests, and joining contests etc. I'll consider making this repo public or granting access upon request.

- Back End: Node, Google Firebase / Firestore / Cloud Functions. Used to maintain a single source of truth and setup / maintain accurate interaction with the smart contract. Also Provides API connection for games to get and post contest gaming data. This handles most of the contest / gamer / API logic, and confirms it on the blockchain by watching for events. I'll consider making this repo public or granting access upon request.

- Snake Example: Open source simple snake react game, wrapped in a simple integration with Game For Crypto. The snake game was originally developed by Maël Drapier (github repo: https://github.com/MaelDrapier/react-simple-snake), I made a modification to the starting conditions for the snake, and wrapped it in a simple GFC API react component which connects to contests, and posts scores back to GFC. You can view the GFC version here: https://github.com/gkemper90/gameforcrypto-snake