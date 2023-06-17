// SPDX-License-Identifier: MIT

pragma solidity ^0.4.17;

contract campaignFactory {
    address[] public deployedCampaigns;

    function createCampaign(uint256 min) public {
        address newCampaign = new Campaign(min, msg.sender);

        deployedCampaigns.push(newCampaign);
    }

    function getDeployedContracts() public view returns (address[]) {
        return deployedCampaigns;
    }
}

contract Campaign {
    struct Request {
        string description;
        uint256 value;
        address recipient;
        bool complete;
        uint256 approverCount;
        mapping(address => bool) approvals;
    }

    Request[] public requests;

    address public manager;
    uint256 public minimumContribution;

    // address[] public approvers;
    mapping(address => bool) public approvers;
    uint256 public approversCount;

    modifier restricted() {
        require(msg.sender == manager);
        _;
    }

    // constructor
    function Campaign(uint256 min, address sender) public {
        manager = sender;
        minimumContribution = min;
    }

    function contribute() public payable {
        require(msg.value > minimumContribution);

        // approvers.push(msg.sender);
        approvers[msg.sender] = true;
        approversCount++;
    }

    function createReq(
        string memory _description,
        uint256 _value,
        address _recipient
    ) public restricted {
        require(approvers[msg.sender]);

        Request memory goingToSave = Request(
            _description,
            _value,
            _recipient,
            false,
            0
        );

        requests.push(goingToSave);
    }

    function approveRequest(uint256 index) public {
        // just make local variable
        Request storage request = requests[index];

        // making sure its a donator
        require(approvers[msg.sender]);
        require(!request.approvals[msg.sender]);

        request.approvals[msg.sender] = true;
        request.approverCount++;
    }

    function finalizeRequest(uint256 index) public restricted {
        Request storage request = requests[index];

        require(request.approverCount > (approversCount / 2));
        require(!request.complete);

        request.recipient.transfer(request.value);

        request.complete = true;
    }
}
