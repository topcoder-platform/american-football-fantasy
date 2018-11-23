/**
 * The application API routes
 */

module.exports = {
  '/platformContract': {
    post: {
      controller: 'AuctionController',
      method: 'setupContract'
    }
  },

  /**
   * Route related to MEMBERS
   */
  '/member/:memberAddress/:memberName': {
    post: {
      controller: 'AuctionController',
      method: 'createMember'
    }
  },
  '/member/:memberAddress': {
    get: {
      controller: 'AuctionController',
      method: 'getMember'
    }
  },

  /**
   * Routes related to PLAYERS
   */
  '/players': {
    post: {
      controller: 'AuctionController',
      method: 'createPlayers'
    }
  },
  '/player/:playerId': {
    get: {
      controller: 'AuctionController',
      method: 'getPlayerDetails'
    }
  },

  '/auction': {
    post: {
      controller: 'AuctionController',
      method: 'startAuction'
    },
    get: {
      controller: 'AuctionController',
      method: 'getResults'
    }
  }
}
