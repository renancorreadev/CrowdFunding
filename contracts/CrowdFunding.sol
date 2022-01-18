// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract CrowdFunding{
    mapping(address => uint) public contributors;
    address public admin;

    uint public noOfContributors;
    uint public minimumContribution;
    uint public deadline; //timestamp
    uint public goal;
    uint raisedAmount;


    event Contribuite(address _address , uint amount);
    event StartContract( uint _deadline, uint _goal);

    constructor(uint _goal, uint _deadline){
        goal = _goal;
        deadline = block.timestamp + _deadline;
        minimumContribution = 100; //100wei
        admin = msg.sender;
        emit StartContract( deadline,  goal);
    }

    receive() payable external{
        contribuite();
    }

    //Function to  contribuite
    function contribuite() public payable {
        require(block.timestamp < deadline, "deadline has passed");
        require(msg.value <= minimumContribution, "contribution is too low");

        if(contributors[msg.sender] == 0){
            noOfContributors++;
        }

        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;
        emit Contribuite(msg.sender, msg.value);
    }

    function getContractBalance() public view returns(uint){
        return address(this).balance;
    }

    
}