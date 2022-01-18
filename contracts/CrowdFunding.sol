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

    struct Request{
        string description;
        address payable recipient;
        uint amount;
        bool completed;
        uint numberOfVotters;
        mapping(address => bool) voters;
    }

    mapping(uint => Request) public requests;
    uint public numberRequest;


    event Contribuite(address _address , uint amount);
    event StartContract( uint _deadline, uint _goal);
    event GetRefunds(address _address, uint _amount);
    event GoalChanged(uint oldGoal, uint newGoal);
    event StartedNewCrowdFund(uint newMinimumContribution, uint newGoal, uint newDeadLine);
    event CreateRequest(string last_description, address last_recipient, uint last_amount);
    event Vote(address _voter, uint _idRequest, bool _vote);
    event Payment(uint _idRequest, bool _isCompleted, uint _amount);

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
        //emit to blockchain
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
        //emit to blockchain
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
        //emit to blockchain
        emit StartedNewCrowdFund(newMinimumContribution, newGoal, newDeadline);
    }

     /**@dev this create new Request for CrowdFunding */
    function createRequest(string memory _description, address payable _recipient, uint _amount) public OnlyOwner{
        Request storage newRequest = requests[numberRequest];
        numberRequest++;
        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.amount = _amount;
        newRequest.completed = false;
        newRequest.numberOfVotters = 0;
        //emit to blockchain
        emit CreateRequest(newRequest.description, newRequest.recipient ,newRequest.amount);
    }  

    /** @dev this is vote function for Request created by admin! */
    function voteRequest(uint _numberRequest) public {
        require(contributors[msg.sender] > 0, "You have not contributed to the crowdfunding");
        Request storage thisRequest = requests[_numberRequest];
        require(thisRequest.voters[msg.sender] == false, "You have already voted");
        thisRequest.voters[msg.sender] = true;
        thisRequest.numberOfVotters++;
        emit Vote(msg.sender, _numberRequest, true);
    }

    function payment(uint _requestNumber)external OnlyOwner{
        require(raisedAmount >=goal, "The goal has not been reached");
        Request storage thisRequest = requests[_requestNumber];
        require(thisRequest.completed == false, "The request has already been completed");
        //it verify that 50% votters 
        require(thisRequest.numberOfVotters > noOfContributors/2, "There are no votes");
        thisRequest.recipient.transfer(thisRequest.amount);
        thisRequest.completed = true;

        //emit to blockchain
        emit Payment(_requestNumber, thisRequest.completed,thisRequest.amount);
    }
}   