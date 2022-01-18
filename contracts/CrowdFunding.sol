// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract CrowdFunding{
    mapping(address => uint) public contributors;
    address public admin;

    uint public noOfContributors;
    uint public minimumContribution;
    uint public deadline; //timestamp
    uint public goal;
    uint public raisedAmount;


    event Contribuite(address _address , uint amount);
    event StartContract( uint _deadline, uint _goal);
    event GetRefunds(address _address, uint _amount);
    event GoalChanged(uint oldGoal, uint newGoal);
    event startedNewCrowdFund(uint newMinimumContribution, uint newGoal, uint newDeadLine);

    constructor(uint _goal, uint _deadline){
        goal = _goal;
        deadline = block.timestamp + _deadline;
        minimumContribution = 100; //100wei
        admin = msg.sender;
        emit StartContract( deadline,  goal);
    }

    modifier OnlyOwner(){
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    receive() payable external{
        contribuite();
    }

    //Function to  contribuite
    function contribuite() public payable {
        require(block.timestamp < deadline, "deadline has passed");
        require(msg.value >= minimumContribution, "contribution is too low");

        if(contributors[msg.sender] == 0){
            noOfContributors++;
        }

        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;
        emit Contribuite(msg.sender, msg.value);
    }

    function getContractBalance() external view returns(uint){
        return address(this).balance;
    }

    function getRefunds() public {
        require(block.timestamp > deadline && raisedAmount < goal, "The deadline is not over yet.");
        require(contributors[msg.sender] > 0, "There were no contributors");

        address payable recipient = payable(msg.sender);
        uint value = contributors[msg.sender];
        recipient.transfer(value);
        //Reset value the contribuitor
        contributors[msg.sender] = 0;
        noOfContributors = noOfContributors - 1 ;
        raisedAmount = raisedAmount - value;
        emit GetRefunds(recipient, value);

    }

    function changeGoal(uint newGoal) external OnlyOwner {
        require(newGoal != goal, "Please enter a different value");
        goal = newGoal;
        emit GoalChanged(goal, newGoal);
    }   

    function StateDeadline()  public view returns(string memory){
        if(block.timestamp > deadline){
            return "CrowdFunding Finished!";
        }else{
            return "CrowdFunding is Running";
        }
    }

    /**@dev this function starts a new round */
    function StartNewCrowFunding(uint newMinimumContribution, uint newGoal, uint newDeadline) external OnlyOwner{
        require(block.timestamp > deadline, "Crowfunding is running");
        require(noOfContributors == 0, "There are still people who have not withdrawn their funds.");
        minimumContribution = newMinimumContribution;
        goal = newGoal;
        deadline = block.timestamp + newDeadline;
        emit startedNewCrowdFund(newMinimumContribution, newGoal, newDeadline);

    }
    
}