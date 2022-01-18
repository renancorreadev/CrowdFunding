// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract CrowdFunding{
    mapping(address => uint) public contributors;
    address public admin;

    uint public noOfContributors;
    uint public minimumContributors;
    uint public deadline; //timestamp
    uint public goal;
    uint raisedAmount;

    constructor(uint _goal, uint _deadline){
        goal = _goal;
        deadline = block.timestamp + _deadline;
        minimumContributors = 100; //100wei
        admin = msg.sender;
    }
}