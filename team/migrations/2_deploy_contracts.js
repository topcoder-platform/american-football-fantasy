var Team = artifacts.require("./CreateTeam.sol");

module.exports = function(deployer) {
  deployer.deploy(Team, "0x67525c93cb13935f72a3afc9f1079f13fdd82c9c");
};
