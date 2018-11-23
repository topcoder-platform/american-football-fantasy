const helper = require('../common/helper')
const AuctionService = require('../services/AuctionService')

async function setupContract (req, res) {
  res.json(await helper.setupContract())
}

async function createMember (req, res) {
  res.json(await AuctionService.createMember(req.params.memberAddress, req.params.memberName))
}

async function getMember (req, res) {
  res.json(await AuctionService.getMember(req.params.memberAddress))
}

async function createPlayers (req, res) {
  res.json(await AuctionService.createPlayers())
}

async function getPlayerDetails (req, res) {
  res.json(await AuctionService.getPlayerDetails(req.params.playerId))
}

async function startAuction (req, res) {
  AuctionService.startAuction()
  res.json({'message': 'Auction has been started'})
}

async function getResults (req, res) {
  res.json(await AuctionService.getResults())
}

module.exports = {
  setupContract,
  createMember,
  getMember,
  createPlayers,
  getPlayerDetails,
  startAuction,
  getResults
}
