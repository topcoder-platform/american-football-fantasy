pragma solidity ^0.4.23;

contract PlatformContract {
    struct Member {
        string name;
        uint points;
        uint[] players;
        uint qb;
        uint rb;
        uint wr;
        uint te;
        uint d;
        uint k;
    }
    mapping (address => Member) members;
    address[] public memberArray;

    struct BidDetail {
        address member;
        uint points;
    }

    struct Player {
        string name;
        string position;
        string playerCode;
        uint playerId;
        bool sold;
        uint currentBidValue;
        address owner;
        mapping (uint => BidDetail) bidDetails;
        address[] bidders;
        uint bidCount;
    }
    mapping (uint => Player) players;
    uint[] playerArray;

    uint TEAM_PLAYER_COUNT = 12;
    uint QB_COUNT = 2;
    uint RB_COUNT = 3;
    uint WR_COUNT = 3;
    uint TE_COUNT = 2;
    uint D_COUNT = 1;
    uint K_COUNT = 1;

    uint playerUnderBidID;

    event Bid(address bidder, uint playerId);

    function createMember(address memberAddress, string name) public {
        Member storage member = members[memberAddress];
        member.name = name;
        member.points = 200;
        delete member.players;
        member.qb = 0;
        member.rb = 0;
        member.wr = 0;
        member.te = 0;
        member.d = 0;
        member.k = 0;
        
        memberArray.push(memberAddress);      
    }
    
    function createPlayer(string _name, string _position, string _playerCode, uint _playerId) public {
        Player storage player = players[_playerId];
        player.name = _name;
        player.position = _position;
        player.playerCode = _playerCode;
        player.playerId = _playerId;
        player.sold = false;
        player.currentBidValue = 1;
        player.bidCount = 0;
        delete player.bidders;
        
        playerArray.push(_playerId);
    }

    function bid(uint pid, address member) public returns (uint) {
        playerUnderBidID = pid;
        CreateTeam c;

        bool eligibility = checkMemberEligibility(member, players[pid].position);
        if (eligibility) {
            c = CreateTeam(member);
            uint bidValue = c.makeBid();

            bool bidEligibility = checkBidEligibility(members[member].points, members[member].players.length, bidValue, players[pid].currentBidValue);

            if (bidEligibility) {
                players[pid].currentBidValue = bidValue;
                players[pid].bidders.push(member);

                players[pid].bidDetails[players[pid].bidCount].member = member;
                players[pid].bidDetails[players[pid].bidCount].points = bidValue;
                players[pid].bidCount = players[pid].bidCount + 1;

                return bidValue;
            } else {
                return 0;
            }
        } else { 
            return 0;
        }
    }

    function playerSold(uint playerId, address memberAddress, uint playerValue) public {
        players[playerId].owner = memberAddress;
        members[memberAddress].points = members[memberAddress].points - playerValue;
        members[memberAddress].players.push(playerId);

        players[playerId].sold = true;
        
        updateTeamComposition(players[playerId].position, memberAddress);     
    }

    function checkMemberEligibility(address memberAddress, string position) public returns (bool) {
        bool positionFlag = false;
        
        if(keccak256(position) == keccak256("QB") && members[memberAddress].qb < QB_COUNT) {
            positionFlag = true;
        } else if(keccak256(position) == keccak256("RB") && members[memberAddress].rb < RB_COUNT) {
            positionFlag = true;
        } else if(keccak256(position) == keccak256("WR") && members[memberAddress].wr < WR_COUNT) {
            positionFlag = true;
        } else if(keccak256(position) == keccak256("TE") && members[memberAddress].te < TE_COUNT) {
            positionFlag = true;
        } else if(keccak256(position) == keccak256("K") && members[memberAddress].k < K_COUNT) {
            positionFlag = true;
        } else if(keccak256(position) == keccak256("DB") && members[memberAddress].d < D_COUNT) {
            positionFlag = true;
        } else if(keccak256(position) == keccak256("DE") && members[memberAddress].d < D_COUNT) {
            positionFlag = true;
        } else if(keccak256(position) == keccak256("DT") && members[memberAddress].d < D_COUNT) {
            positionFlag = true;
        }

        bool playerCountFlag = false;
        if (members[memberAddress].players.length < TEAM_PLAYER_COUNT) {
            playerCountFlag = true;    
        }

        if (playerCountFlag == true && positionFlag == true) {
            return true;
        } else {
            return false;
        }
    }

    function checkBidEligibility(uint remainingTeamPoints, uint teamPlayerCount, uint bidValue, uint lastBidValue) public returns (bool) {
        uint max_bid_value = remainingTeamPoints - (TEAM_PLAYER_COUNT - teamPlayerCount);
        if (bidValue != 0 && bidValue <= 200 && bidValue <= max_bid_value && bidValue > lastBidValue) {
            return true;
        } else {
            return false;
        }
    }

    function updateTeamComposition(string position, address memberAddress) public {
        if(keccak256(position) == keccak256("QB")) {
            members[memberAddress].qb++;
        } else if(keccak256(position) == keccak256("RB")) {
            members[memberAddress].rb++;
        } else if(keccak256(position) == keccak256("WR")) {
            members[memberAddress].wr++;
        } else if(keccak256(position) == keccak256("TE")) {
            members[memberAddress].te++;
        } else if(keccak256(position) == keccak256("K")) {
            members[memberAddress].k++;
        } else if(keccak256(position) == keccak256("DB")) {
            members[memberAddress].d++;
        } else if(keccak256(position) == keccak256("DE")) {
            members[memberAddress].d++;
        } else if(keccak256(position) == keccak256("DT")) {
            members[memberAddress].d++;
        }
    }
    
    function assignPlayer(address teamAddress, uint playerId) public {
        members[teamAddress].points = members[teamAddress].points - 1;
        members[teamAddress].players.push(playerId);

        players[playerId].sold = true;
    } 

    function getRemainingTeams() public returns (address[]) {
        address[] remainingTeams;
        for (uint i = 0; i < memberArray.length; i++) {
            if (members[memberArray[i]].players.length < TEAM_PLAYER_COUNT) {
                remainingTeams.push(memberArray[i]);
            }
        } 
        return remainingTeams;   
    }

    function getPlayerIds() public returns (uint[]) {
        return playerArray;  
    }

    function getMembers() public returns (address[]) {
        return memberArray;
    }

    function getMembersDetails(address _address) public returns (string, uint, uint[], uint, uint, uint, uint, uint, uint) {
        Member memory m = members[_address];
        return (
            m.name, 
            m.points, 
            m.players, 
            m.qb, 
            m.rb, 
            m.wr, 
            m.te, 
            m.d, 
            m.k
        );
    }

    function getPlayerDetails(uint _playerId) public returns (string, string, string, uint, bool, address, address[], uint) {
        Player memory p = players[_playerId];
        return (
            p.name, 
            p.position, 
            p.playerCode, 
            p.currentBidValue, 
            p.sold, 
            p.owner,
            p.bidders,
            p.bidCount
        );
    }

    function getBidderDetails(uint pid, uint index) public returns (address, uint) {
        return (players[pid].bidDetails[index].member, players[pid].bidDetails[index].points);
    }

    function getCurrentBalance() public returns (uint) {
        return members[msg.sender].points;    
    }

    function getPlayerCount() public returns (uint) {
        return members[msg.sender].players.length;    
    }

    function getMyPlayers() public returns (uint[]) {
        return members[msg.sender].players;
    }

    function getPlayer(uint _pid) public returns (string name, string position, string playerCode, uint currentBidValue) {
        uint pid;
        
        if (_pid == 0) {
            pid = playerUnderBidID;
        } else {
            pid = _pid;
        }

        return (
            players[pid].name,
            players[pid].position,
            players[pid].playerCode,
            players[pid].currentBidValue
        );
    }
}

contract CreateTeam {
    function makeBid() public returns(uint);
}

