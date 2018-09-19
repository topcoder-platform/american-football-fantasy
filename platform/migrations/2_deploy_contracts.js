var Platform = artifacts.require("./PlatformContract.sol");

module.exports = function(deployer) {
  deployer.deploy(Platform);
};
