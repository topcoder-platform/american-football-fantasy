pragma solidity ^0.4.23;

contract PlatformContract {
    struct Player {
        string name;
        string position;
        string playerCode;
        uint playerId;
        bool sold;
    }
    mapping (uint => Player) players;
    uint[] playerArray;
    
    struct Member {
        uint points;
        uint[] players;
    }
    mapping (address => Member) members;
    address[] public memberArray;

    struct BidingValue {
        address member;
        uint points;
    }

    struct BidingPlayer {
        string name;
        string position;
        string playerCode;
        uint playerId;
        uint currentBidValue;
        address owner;
        mapping (uint => BidingValue) bidingValue;
        address[] bidders;
    }
    mapping (uint => BidingPlayer) bidingPlayers;
    uint[] bidingPlayerArray;

    uint bidCount = 0;
    uint bidderCount = 0;

    uint[] unsoldPlayers;
    address[] remainingTeams;

    uint TEAM_PLAYER_COUNT = 15;

    function createTeam(address memberAddress) public returns (bool, uint) {
        Member storage member;
        if (memberArray.length > 0) {
            for (uint  i = 0; i < memberArray.length; i++) {
                if(memberArray[i] == memberAddress)
                    return (false, i);
                else {
                    member = members[memberAddress];
                    member.points = 200;
                    memberArray.push(memberAddress);
                    return (true, i);
                }      
            }
        } else {
            member = members[memberAddress];
            member.points = 200;
            memberArray.push(memberAddress);
            return (true, 0);    
        }
        
    }
    
    function createPlayerPool(string _name, string _position, string _playerCode, uint _playerId) public {
        Player storage player = players[_playerId];
        player.name = _name;
        player.position = _position;
        player.playerCode = _playerCode;
        player.playerId = _playerId;
        player.sold = false;
        
        playerArray.push(_playerId);
    }

    function initiateBid(uint pid) public {
        // for (uint pid = 1; pid <= playerArray.length; pid++) {
        BidingPlayer storage bidingPlayer = bidingPlayers[pid];
        bidingPlayer.name = players[pid].name;
        bidingPlayer.position = players[pid].position;
        bidingPlayer.playerCode = players[pid].playerCode;
        bidingPlayer.playerId = players[pid].playerId;
        bidingPlayer.currentBidValue = 1;

        bidingPlayerArray.push(pid);

        CreateTeam c;

        bidCount = 0;
        bidderCount = 0;
        for (uint i = 0; i < memberArray.length; i++) {
            uint currentHoldingPlayers = members[memberArray[i]].players.length;
            if(currentHoldingPlayers < TEAM_PLAYER_COUNT) {
                c = CreateTeam(memberArray[i]);
                uint bidValue = c.makeBid();

                uint max_bid_value = members[memberArray[i]].points - (TEAM_PLAYER_COUNT - currentHoldingPlayers);

                if (bidValue != 0 && bidValue <= 200 && bidValue <= max_bid_value && bidValue > bidingPlayers[pid].currentBidValue) {
                    bidingPlayers[pid].currentBidValue = bidValue;
                    bidingPlayers[pid].bidders.push(memberArray[i]);
                    bidingPlayers[pid].bidingValue[bidCount] = BidingValue({points: bidValue, member: memberArray[i]});

                    bidderCount++;
                    bidCount++;
                }
            }  
        }

        uint finalPoints;
        address winner;

        if (bidderCount == 1) {
            finalPoints = bidingPlayers[pid].bidingValue[0].points;
            winner = bidingPlayers[pid].bidingValue[0].member;

            bidingPlayers[pid].owner = winner;
            members[winner].points = members[winner].points - finalPoints;
            members[winner].players.push(pid);

            players[pid].sold = true;    
        } else if (bidderCount > 1) {
            while(bidderCount == 1) {
                bidNextRound(pid, max_bid_value);
            }

            finalPoints = bidingPlayers[pid].bidingValue[bidCount - 1].points;
            winner = bidingPlayers[pid].bidingValue[bidCount - 1].member;

            bidingPlayers[pid].owner = winner;
            members[winner].points = members[winner].points - finalPoints;
            members[winner].players.push(pid);

            players[pid].sold = true;
        }
    }

    function bidNextRound(uint pid, uint max_bid_value) private {
        for (uint i = 0; i < bidingPlayers[pid].bidders.length; i++) {
            CreateTeam c = CreateTeam(bidingPlayers[pid].bidders[i]);
            uint bidValue = c.makeBid();

            if (bidValue > 0 && bidValue <= 200 && bidValue <= max_bid_value && bidValue > bidingPlayers[pid].currentBidValue) {
                bidingPlayers[pid].currentBidValue = bidValue;
                bidingPlayers[pid].bidingValue[bidCount++] = BidingValue({points: bidValue, member: bidingPlayers[pid].bidders[i]});
            } else {
                if(bidderCount > 1) {
                    bidderCount--;
                    delete bidingPlayers[pid].bidders[i];
                }   
            }
        }
    }

    function completeTeams() public {
        uint playerIndex = 0;
        
        for(uint i = 0; i < remainingTeams.length; i++) {
            uint[] memory temp = getOwnedPlayers(remainingTeams[i]);
            uint remainingMembers = TEAM_PLAYER_COUNT - temp.length;

            for(uint j = 0; j < remainingMembers; j++) {
                assignPlayer(remainingTeams[i], unsoldPlayers[playerIndex]);
                playerIndex++;
            } 
        }
    }
    
    function assignPlayer(address teamAddress, uint playerId) public {
        members[teamAddress].points = members[teamAddress].points - 1;
        members[teamAddress].players.push(playerId);

        players[playerId].sold = true;
    } 

    function getPlayerArray(uint index) public returns (uint) {
        return playerArray[index];
    }

    function getRemainingTeams() public returns (address[]) {
        for (uint i = 0; i < memberArray.length; i++) {
            if (members[memberArray[i]].players.length < TEAM_PLAYER_COUNT) {
                remainingTeams.push(memberArray[i]);
            }
        } 

        return remainingTeams;   
    }

    function getUnsoldPlayers() public returns (uint[]) {
        for (uint i = 0; i < playerArray.length; i++) {
            if (!players[playerArray[i]].sold) {
                unsoldPlayers.push(playerArray[i]);
            }
        }

        return unsoldPlayers;   
    }

    function getTeamAddresses() public returns (address[]) {
        return memberArray;
    }

    function getTeamDetails(address _address) public returns (uint, uint[]) {
        return (members[_address].points, members[_address].players);
    }

    function getCurrentBalance() public returns (uint) {
        return members[msg.sender].points;    
    }

    function getPlayerCount() public returns (address) {
        return msg.sender;    
    }

    function getMyPlayers() public returns (uint[]) {
        return members[msg.sender].players;
    }

    function getPlayerDetails(uint _playerId) public returns (string, string, string, uint, bool, address) {
        return (
            players[_playerId].name, 
            players[_playerId].position, 
            players[_playerId].playerCode, 
            bidingPlayers[_playerId].currentBidValue, 
            players[_playerId].sold, 
            bidingPlayers[_playerId].owner
        );
    }

    function getPlayers() public returns (uint[]) {
        return playerArray;
    }

    function getOwnedPlayers(address memberAddress) public returns (uint[]) {
        return members[memberAddress].players;
    }

    function getBidder(uint pid, uint index) public returns (address) {
        return bidingPlayers[pid].bidingValue[index].member;
    }

    function getCurrentPlayerPosition() public returns (string) {
        return bidingPlayers[bidingPlayerArray.length].position;
    }

    function getCurrentPlayerCode() public returns (string) {
        return bidingPlayers[bidingPlayerArray.length].playerCode;
    }

    function getCurrentBidValue() public returns (uint) {
        return bidingPlayers[bidingPlayerArray.length].currentBidValue;
    }
}

contract CreateTeam {
    function makeBid() public returns(uint);
}

