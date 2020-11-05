const Byx88 = artifacts.require("Byx88");

module.exports = function (deployer, network, accounts) {
  if (accounts[0] !== "0xBEF473cE6738d73df0351107CC6f9A087CA0d00a") {
    return;
  }

  deployer.deploy(Byx88);
};
