pragma solidity ^0.7.0;

contract GameForCrypto {

    unit256 creditValue;
    string public creditTokenName;
    enum State { Waiting, Ready, Active }

    constructor (string memory _tokenName) public {
        console.log('Setting Credit Token: ', _tokenName);
        creditTokenName = _tokenName;

        //Get Price of Token From Chainlink Oracle
    }

    function addGamer (address sender) public {
        //Add Gamer To Smart Contract
        //Requires Token Deposit

    }

    function updateGamerCredits () {
        //Convert Deposit To Credits Balance
        //Save Balance On Blockchain

    }

    function removeGamerCredits () {
        //Adjust Gamer Credit Balance
    }

    function removeGamer () {
        //Remove Gamer From Smart Contract
    }

    function withdrawlGamerCredits () {
        //Withdrawl Credits To Gamer
    }

    function transferGamerCredits () {
        //Transfer Credits From Pool To Gamer
    }

}