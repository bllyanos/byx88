// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

import "@openzeppelin/contracts/math/SafeMath.sol";

contract Byx88 {
    // safe-math from openzeppelin
    using SafeMath for uint256;

    address payable public owner;

    string public version = "1.0.0";

    enum Statuses {PENDING, VERIFIED, REJECTED}

    constructor() public {
        // init owner on construct
        owner = msg.sender;
    }

    /** Deposit structure */
    struct Deposit {
        address payable sender;
        string target; // gwallet account
        uint256 amount; // in wei
        Statuses status;
    }

    /** Withdrawal structure */
    struct Withdrawal {
        string source; // gwallet account
        string target; // eth account
        uint256 amount; // in wei
    }

    // mapping(uint256 => Deposit) public deposits;

    Deposit[] deposits;

    function fill() public payable restricted returns (bool) {
        emit FillBalance(msg.value);
        return true;
    }

    function take(uint256 amount) public restricted returns (bool) {
        require(address(this).balance >= amount, "InsufficientBalance");
        owner.transfer(amount);
        emit Take(owner, amount);
    }

    // init deposit
    function deposit(string memory target) public payable returns (uint256) {
        uint256 id = deposits.length;
        deposits.push(Deposit(msg.sender, target, msg.value, Statuses.PENDING));
        emit DepositInit(id, msg.value);
        return id;
    }

    // verify the transaction by its ID
    function verify(uint256 id) public restricted returns (bool) {
        require(deposits[id].status == Statuses.PENDING);
        deposits[id].status = Statuses.VERIFIED;
        emit VerifiedDeposit(id, deposits[id].amount);
        return true;
    }

    // reject the transaction by its ID
    function reject(uint256 id) public restricted returns (bool) {
        deposits[id].status = Statuses.REJECTED;
        deposits[id].sender.transfer(deposits[id].amount);
        emit RejectedDeposit(id, deposits[id].amount);
        return true;
    }

    function withdraw(
        uint256 ref,
        string memory source,
        address payable to,
        uint256 amount
    ) public restricted returns (bool) {
        require(address(this).balance >= amount);
        to.transfer(amount);
        emit Withdraw(ref, source, to, amount);
        return true;
    }

    function getFirstPendingDeposit() public view restricted returns (uint256) {
        for (uint256 i = 0; i < deposits.length; i++) {
            if (deposits[i].status == Statuses.PENDING) {
                return i + 1;
            }
        }
        return 0;
    }

    function setVersion(string memory newVersion) public restricted {
        version = newVersion;
    }

    function transferOwnership(address payable target) public restricted {
        owner = target;
    }

    modifier restricted() {
        require(msg.sender == owner, "Forbidden actions");
        _;
    }

    // id: deposit id
    event DepositInit(uint256 id, uint256 amount);

    // id: deposit id
    event VerifiedDeposit(uint256 id, uint256 amount);

    // id: deposit id
    event RejectedDeposit(uint256 id, uint256 amount);

    // sender: eth account
    // source: gwallet account
    // amount: eth amount, in wei
    event Withdraw(uint256 ref, string source, address to, uint256 amount);

    // transfer ETH to contract
    event FillBalance(uint256 amount);

    // transfer balance from contract to owner
    event Take(address payable to, uint256 amount);

    event ChangeOwner(address from, address to);
}
