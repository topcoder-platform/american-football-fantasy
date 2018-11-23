pragma solidity ^0.4.23;

contract CreateTeam {
    address platformAddress;

    uint private MAX_VALUE = 200;
    uint private MAX_PLAYERS_PER_TEAM = 12;

    constructor(address _platformAddress) public {
        platformAddress = _platformAddress;
    }

    /**
    Implement "createBid() function with your preferences
     */
    function createBid(string playerCode, string position, uint currentValue) private returns (uint256) {
        PlatformContract platformContract = PlatformContract(platformAddress);
        
        uint playerCount = platformContract.getPlayerCount();
        if (playerCount == MAX_PLAYERS_PER_TEAM) {
            return 0;
        }
        
        uint newBidValue = currentValue + 5;
        uint currentBalance = platformContract.getCurrentBalance();

        if (newBidValue < MAX_VALUE && newBidValue <= currentBalance) {
            return newBidValue;
        } else {
            return 0;
        }
    }

    function makeBid() public returns (uint) {
        PlatformContract platformContract = PlatformContract(platformAddress);
        
        string memory position;
        string memory playerCode;
        uint currentBidValue;
        
        (, position, playerCode, currentBidValue) = platformContract.getPlayer(0);

        return createBid(playerCode, position, currentBidValue);
    }
}


contract PlatformContract {
    // Returns the Position of the player under auction (send pid = 0 to get details of player under bid)
    function getPlayer(uint pid) public returns (string name, string position, string playerCode, uint currentBidValue);
    
    // Returns the Remaining Balance of the team
    function getCurrentBalance() public returns (uint currentBalance);
    
    // Returns total number of won players
    function getPlayerCount() public returns (uint playerCount);
    
    // Returns array of PlayerIds of won players
    function getMyPlayers() public returns (uint[] playerList);
}
