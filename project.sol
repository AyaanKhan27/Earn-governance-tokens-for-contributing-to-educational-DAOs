// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract EduGovernanceDAO {

    struct Contribution {
        string description;
        uint256 timestamp;
    }

    struct Proposal {
        string description;
        uint256 votesFor;
        uint256 votesAgainst;
        bool executed;
    }

    address public owner;
    uint256 public tokenSupply;
    mapping(address => uint256) public tokenBalance;
    mapping(address => Contribution[]) public contributions;
    Proposal[] public proposals;

    event ContributionMade(address contributor, string description, uint256 tokensAwarded);
    event ProposalCreated(uint256 proposalId, string description);
    event Voted(uint256 proposalId, address voter, bool support);
    event ProposalExecuted(uint256 proposalId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    modifier onlyContributor() {
        require(tokenBalance[msg.sender] > 0, "Not a contributor");
        _;
    }

    constructor(uint256 _initialSupply) {
        owner = msg.sender;
        tokenSupply = _initialSupply;
        tokenBalance[owner] = _initialSupply;
    }

    function contribute(string memory description, uint256 tokensAwarded) public {
        require(tokensAwarded <= tokenBalance[owner], "Insufficient tokens in DAO");
        
        contributions[msg.sender].push(Contribution({
            description: description,
            timestamp: block.timestamp
        }));

        tokenBalance[owner] -= tokensAwarded;
        tokenBalance[msg.sender] += tokensAwarded;

        emit ContributionMade(msg.sender, description, tokensAwarded);
    }

    function createProposal(string memory description) public onlyContributor {
        proposals.push(Proposal({
            description: description,
            votesFor: 0,
            votesAgainst: 0,
            executed: false
        }));

        emit ProposalCreated(proposals.length - 1, description);
    }

    function vote(uint256 proposalId, bool support) public onlyContributor {
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "Proposal already executed");

        if (support) {
            proposal.votesFor++;
        } else {
            proposal.votesAgainst++;
        }

        emit Voted(proposalId, msg.sender, support);
    }

    function executeProposal(uint256 proposalId) public onlyOwner {
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "Proposal already executed");
        require(proposal.votesFor > proposal.votesAgainst, "Proposal did not pass");

        proposal.executed = true;

        emit ProposalExecuted(proposalId);
    }

    function getContributions(address contributor) public view returns (Contribution[] memory) {
        return contributions[contributor];
    }

    function getProposals() public view returns (Proposal[] memory) {
        return proposals;
    }
}
