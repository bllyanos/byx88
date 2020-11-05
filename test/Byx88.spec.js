const chai = require("chai")
chai.use(require("chai-as-promised"))

const BN = require('bn.js');

const expect = chai.expect

const Byx88 = artifacts.require("Byx88")

contract("Byx88", accounts => {

  let wallet
  beforeEach(async () => {
    wallet = await Byx88.new()
  })

  describe("get Pending Deposit", () => {
    it("should not error", async () => {
      const result = await wallet.deposit(accounts[0], { from: accounts[0], value: "100000000000000000" });
      const result2 = await wallet.deposit(accounts[0], { from: accounts[0], value: "100000000000000000" });
      const result3 = await wallet.deposit(accounts[0], { from: accounts[0], value: "100000000000000000" });
      const result4 = await wallet.deposit(accounts[0], { from: accounts[0], value: "100000000000000000" });

      await wallet.verify(0, { from: accounts[0] });
      await wallet.verify(1, { from: accounts[0] });
      await wallet.verify(3, { from: accounts[0] });


      const data = await wallet.getFirstPendingDeposit({ from: accounts[0] });
      console.log(data, data.toString());

      const reject = await wallet.reject(new BN(1));

      const data2 = await wallet.getFirstPendingDeposit({ from: accounts[0] });
      console.log(data2.toString())

      let balance = await web3.eth.getBalance(wallet.address);
      console.log(balance);

      const take = await wallet.take("200000000000000000");
      const trans1 = await wallet.getDeposit(1);
      console.log(trans1);

      balance = await web3.eth.getBalance(wallet.address);
      console.log(balance);
    });
  });

});