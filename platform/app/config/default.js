/**
 * The configuration file.
 */

module.exports = {
  LOG_LEVEL: process.env.LOG_LEVEL || 'debug',
  PORT: process.env.PORT || 3000,

  GANACHE_URL: process.env.GANACHE_URL || 'http://127.0.0.1:8545',
  AUCTIONEER_ADDRESS: process.env.AUCTIONEER_ADDRESS || '0x1ddf2db8a66bf00f8528c44e31ae277bb43bc0ea',
  DEFAULT_GAS: process.env.DEFAULT_GAS || 3000000
}
