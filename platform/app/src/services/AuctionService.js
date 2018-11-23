const config = require('config')
const path = require('path')
const schema = require('schm')

const helper = require('../common/helper')
const logger = require('../common/logger')
const Players = require(path.join(__dirname, '../../Players.json'))

const desiredTeamComposition = {
  qb: 2,
  rb: 3,
  wr: 3,
  te: 2,
  d: 1,
  k: 1
}

let unsoldPlayers = [];

const bidDetailSchema = schema({
  member: String,
  bidValue: String
})

const playerSchema = schema({
  id: String,
  name: String,
  position: String,
  playerCode: String,
  sold: Boolean,
  owner: String,
  value: String,
  bidCount: String,
  bidDetails: [bidDetailSchema]
})

const teamCompositionSchema = schema({
  QB: String,
  RB: String,
  WR: String,
  TE: String,
  D: String,
  K: String
})

const memberSchema = schema({
  name: String,
  points: String,
  players: [playerSchema],
  teamComposition: teamCompositionSchema
})

const createMember = async (memberAddress, memberName) => {
  const contractInstance = await helper.getPlatFormContract()
  return contractInstance.createMember(
    memberAddress, 
    memberName, 
    { from: config.AUCTIONEER_ADDRESS, gas: config.DEFAULT_GAS }
  )
}

const getMember = async (memberAddress) => {
  const contractInstance = await helper.getPlatFormContract()
  let memberDetails = await contractInstance.getMembersDetails.call(memberAddress)

  let players = []
  for (let i = 0; i < memberDetails[2].length; i++) {
    let playerDetails = await getPlayerDetails(memberDetails[2][i])
    players.push(playerDetails)
  }

  let teamComposition = teamCompositionSchema.parse({
    QB: memberDetails[3],
    RB: memberDetails[4],
    WR: memberDetails[5],
    TE: memberDetails[6],
    D: memberDetails[7],
    K: memberDetails[8]
  })

  return memberSchema.parse({ 
    name: memberDetails[0], 
    points: memberDetails[1], 
    players: players, 
    teamComposition: teamComposition 
  })
}

const createPlayers = async (memberAddress) => {
  const contractInstance = await helper.getPlatFormContract()

  for (let i = 0; i < Players.length; i++) {
    await contractInstance.createPlayer(
      Players[i].name, 
      Players[i].position, 
      Players[i].playerCode, 
      Players[i].id, 
      { from: config.AUCTIONEER_ADDRESS, gas: config.DEFAULT_GAS }
    )
  }

  return { 'message': 'Players Created' }
}

const getPlayerDetails = async (playerId) => {
  const contractInstance = await helper.getPlatFormContract()
  let playerDetails = await contractInstance.getPlayerDetails.call(playerId)

  let bidDetails = []
  if (playerDetails[6].length > 0) {
    for (let i = 0; i < playerDetails[6].length; i++) {
      let bidDetail = await contractInstance.getBidderDetails.call(playerId, i)
      bidDetails.push(bidDetailSchema.parse({
        id: playerId,
        member: bidDetail[0],
        bidValue: bidDetail[1].toString()
      }))
    }
  }

  return playerSchema.parse({
    name: playerDetails[0],
    position: playerDetails[1],
    playerCode: playerDetails[2],
    sold: playerDetails[4],
    owner: playerDetails[5],
    value: playerDetails[3],
    bidCount: playerDetails[7],
    bidDetails: bidDetails || []
  })
}

const assignRemainingPlayers = async (position, expectedCount, actualCount, memberAddress) => {
  const contractInstance = await helper.getPlatFormContract();
  
  for (let i = 0; i < expectedCount - actualCount; i++) {
    playerId = unsoldPlayers.filter((player) => {
      if (position == 'D') {
        return player.position == 'DE' || player.position == 'DB' || player.position == 'DT'
      } else {
        return player.position == position
      }
    })[i].id

    await contractInstance.playerSold(playerId, 
      memberAddress, 
      1, 
      { from: config.AUCTIONEER_ADDRESS, gas: config.DEFAULT_GAS }
    );

    let index = unsoldPlayers.findIndex(function(player, j){
      return player.id === playerId
    });

    unsoldPlayers.splice(index, 1);
  }
}

const completeAuction = async () => {
  const contractInstance = await helper.getPlatFormContract();;
  
  let playerArray = await contractInstance.getPlayerIds.call();

  let allPlayers = []
  for (let i = 0; i < playerArray.length; i++) {
    let playerDetails = await contractInstance.getPlayerDetails.call(playerArray[i])
    allPlayers.push(
      playerSchema.parse({
        id: playerArray[i],
        name: playerDetails[0],
        position: playerDetails[1],
        playerCode: playerDetails[2],
        sold: playerDetails[4],
      })
    )
  }

  unsoldPlayers = allPlayers.filter((player) => {
    return player.sold == false
  });

  let positionKeys = Object.keys(desiredTeamComposition);

  let remainingTeams = await contractInstance.getRemainingTeams.call();
  for (i = 0; i < remainingTeams.length; i++) {
    let team = await getMember(remainingTeams[i]);
    let teamComposition = team.teamComposition;

    for (let j = 0; j < positionKeys.length; j++) {
      let position = positionKeys[j].toUpperCase();
      let actualCount = parseInt(teamComposition[position], 10);
      let expectedCount = desiredTeamComposition[positionKeys[j]];

      if (actualCount < expectedCount) {
        await assignRemainingPlayers(position, expectedCount, actualCount, remainingTeams[i])
      }
    }
  }

  return { 'message': 'Auction Completed' }
}

const bidNextRound = async (playerId, bidders, contractInstance) => {
  for (let j = 0; j < bidders.length; j++) {
    let res = await contractInstance.bid.call(playerId, bidders[j])

    if (parseInt(res.toString(), 10) > 0) {
      await contractInstance.bid(playerId, bidders[j], { from: config.AUCTIONEER_ADDRESS, gas: config.DEFAULT_GAS })
    } else {
      let index = bidders.indexOf(bidders[j])
      bidders.splice(index, 1)
    }
  }

  return bidders
}

const bidFirstRound = async (playerId, contractInstance) => {
  let bidders = await contractInstance.getMembers.call()

  for (let i = 0; i < bidders.length; i++) {
    await contractInstance.bid(playerId, bidders[i], { from: config.AUCTIONEER_ADDRESS, gas: config.DEFAULT_GAS })
  }

  let playerDetails = await contractInstance.getPlayerDetails.call(playerId)
  let totalBidders = playerDetails[6]

  if (totalBidders.length > 1) {
    do {
      totalBidders = await bidNextRound(playerId, totalBidders, contractInstance)
    } while (totalBidders.length > 1)
  }

  playerDetails = await contractInstance.getPlayerDetails.call(playerId)

  if (playerDetails[7] == 0) {
    logger.info('No Bidders for Player ID: ' + playerId);
  } else {
    let bidDetail = await contractInstance.getBidderDetails.call(playerId, playerDetails[7] - 1)

    await contractInstance.playerSold(playerId, 
      bidDetail[0], 
      bidDetail[1], 
      { from: config.AUCTIONEER_ADDRESS, gas: config.DEFAULT_GAS }
    );

    logger.info("Player ID: " + playerId + " Sold to " + bidDetail[0] + " for " + bidDetail[1].toString() + " points");
  }
}

const startAuction = async () => {
  const contractInstance = await helper.getPlatFormContract();
  
  for (let i = 0; i < Players.length; i++) {
    await bidFirstRound(Players[i].id,contractInstance);
  }

  await completeAuction();

  logger.info('Auction has been completed and teams are ready to compete !!!')
}

const getResults = async () => {
  const contractInstance = await helper.getPlatFormContract();
  const members = await contractInstance.getMembers.call();

  let result = [];

  for (let i = 0; i < members.length; i++) {
    let memberDetail = await getMember(members[i])
    result.push(memberDetail)
  }
  
  return result;
}

module.exports = {
  createMember,
  getMember,
  createPlayers,
  getPlayerDetails,
  startAuction,
  getResults
}
