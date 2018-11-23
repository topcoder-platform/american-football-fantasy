/**
 * Contains generic helper methods
 */

const _ = require('lodash')
const config = require('config')
const path = require('path')
const contract = require('truffle-contract')
const Web3 = require('web3')

const PlatformContractJSON = require(path.join(__dirname, '../../../build/contracts/PlatformContract.json'))

var PlatformContract

/**
 * Wrap async function to standard express function
 * @param {Function} fn the async function
 * @returns {Function} the wrapped function
 */
const wrapExpress = fn => (req, res, next) => {
  fn(req, res, next).catch(next)
}

/**
 * Wrap all functions from object
 * @param obj the object (controller exports)
 * @returns {Object|Array} the wrapped object
 */
const autoWrapExpress = (obj) => {
  if (_.isArray(obj)) {
    return obj.map(autoWrapExpress)
  }
  if (_.isFunction(obj)) {
    if (obj.constructor.name === 'AsyncFunction') {
      return wrapExpress(obj)
    }
    return obj
  }
  _.each(obj, (value, key) => {
    obj[key] = autoWrapExpress(value)
  })
  return obj
}

const setupContract = async () => {
  PlatformContract = contract(PlatformContractJSON)

  var provider = new Web3(new Web3.providers.HttpProvider(config.GANACHE_URL))
  PlatformContract.setProvider(provider.currentProvider)
  if (typeof PlatformContract.currentProvider.sendAsync !== 'function') {
    PlatformContract.currentProvider.sendAsync = function () {
      return PlatformContract.currentProvider.send.apply(
        PlatformContract.currentProvider, arguments
      )
    }
  }

  return PlatformContract
}

const getPlatFormContract = async () => {
  if (PlatformContract === undefined) {
    setupContract()
  }

  return await PlatformContract.deployed()
}

module.exports = {
  wrapExpress,
  autoWrapExpress,
  setupContract,
  getPlatFormContract
}
