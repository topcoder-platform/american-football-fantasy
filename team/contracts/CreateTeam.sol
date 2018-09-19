pragma solidity ^0.4.23;

contract CreateTeam {
    address platformAddress;

    uint private MAX_VALUE;

    constructor(address _platformAddress) public {
        platformAddress = _platformAddress;
        MAX_VALUE = 50;
    }

    /**
    Implement "createBid() function with your preferences
     */
    function createBid(string playerCode, string position, uint currentValue) private returns (uint256) {
        uint tempValue = currentValue + 5;

        if (tempValue < MAX_VALUE) {
            return tempValue;
        } else {
            return 0;
        }

    }

    function makeBid() public returns (uint) {
        PlatformContract platformContract = PlatformContract(platformAddress);
        
        var position = platformContract.getCurrentPlayerPosition();
        var  playerCode = platformContract.getCurrentPlayerCode();
        uint currentBidValue = platformContract.getCurrentBidValue();

        return createBid(playerCode, position, currentBidValue);
    }
}


contract PlatformContract {
    function getCurrentPlayerPosition() public returns (string);
    function getCurrentPlayerCode() public returns (string);
    function getCurrentBidValue() public returns (uint);
    function getCurrentBalance() public returns (uint);
    function getPlayerCount() public returns (uint);
    function getMyPlayers() public returns (uint[]);
}