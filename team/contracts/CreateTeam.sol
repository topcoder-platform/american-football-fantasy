pragma solidity ^0.4.23;

contract CreateTeam {
    address platformAddress;

    uint private MAX_VALUE;

    constructor(address _platformAddress) public {
        platformAddress = _platformAddress;
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
    // Returns the Position of the player under auction
    function getCurrentPlayerPosition() public returns (string currentPosition);
    
    // Returns the PlayerCode of the player under auction
    function getCurrentPlayerCode() public returns (string currentPlayerCode);
    
    // Returns the Current Bid Value of the player under auction
    function getCurrentBidValue() public returns (uint currentBidValue);
    
    // Returns the Remaining Balance of the team
    function getCurrentBalance() public returns (uint currentBalance);
    
    // Returns total number of won players
    function getPlayerCount() public returns (uint playerCount);
    
    // Returns array of PlayerIds of won players
    function getMyPlayers() public returns (uint[] playerList);
    
    // Returns the details of Player
    function getPlayerDetails(uint _playerId) public returns (string playerName, string playerPosition, string playerCode, uint currentValue, bool sold, address ownerAddress);
}
