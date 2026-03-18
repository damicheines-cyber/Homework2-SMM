// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Staking {

    address public owner;
    uint public minimumStake = 1 ether;

    mapping(address => uint) public stakes;

    event Staked(address user, uint amount);
    event Released(address user, uint amount);
    event Slashed(address user);

    constructor() payable {
        owner = msg.sender;
        require(msg.value >= minimumStake, "Minimum funding required");
    }

    function stake() public payable {
        require(msg.value >= minimumStake, "Stake too small");

        stakes[msg.sender] += msg.value;
        emit Staked(msg.sender, msg.value);
    }

    function releaseStake(address proposer) public {

        uint amount = stakes[proposer];
        require(amount > 0, "No stake found");

        stakes[proposer] = 0;
        payable(proposer).transfer(amount);

        emit Released(proposer, amount);
    }

    function slashStake(address proposer) public {
        stakes[proposer] = 0;
        emit Slashed(proposer);
    }
}