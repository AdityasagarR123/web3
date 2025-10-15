// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title SentimentVoting
 * @dev A smart contract for a voting system where the final outcome is
 * influenced by a sentiment score. This score is intended to be set by an
 * oracle that analyzes social sentiment regarding the proposal.
 *
 * How it works:
 * 1. A proposal is created and voting starts.
 * 2. Users cast their votes as Positive, Negative, or Neutral.
 * 3. An external entity (simulated here by an owner) updates a sentiment score
 * (an integer from -100 to 100).
 * 4. When voting ends, the sentiment score is used as a weight.
 * - A positive score boosts the weight of "Positive" votes.
 * - A negative score boosts the weight of "Negative" votes.
 * 5. The final result is determined by the weighted tally.
 */
contract SentimentVoting {

    // --- State Variables ---

    string public proposal;
    uint256 public positiveVotes;
    uint256 public negativeVotes;
    uint256 public neutralVotes;
    
    // Represents the sentiment score, from -100 (very negative) to 100 (very positive).
    int256 public sentimentScore; 
    
    // Address of the contract owner/deployer.
    address public owner;

    // To track which addresses have already voted to prevent double voting.
    mapping(address => bool) public hasVoted;

    // To control the voting period.
    bool public votingOpen;

    // --- Events ---

    event ProposalSet(string _proposal);
    event VoteCast(address indexed voter, VoteOption option);
    event SentimentUpdated(int256 newScore);
    event VotingEnded(uint256 finalPositive, uint256 finalNegative, string result);

    // --- Enums ---

    enum VoteOption { Negative, Neutral, Positive }
    
    // --- Modifiers ---

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    modifier whenVotingIsOpen() {
        require(votingOpen, "Voting is not currently open.");
        _;
    }

    // --- Functions ---

    /**
     * @dev Sets the contract deployer as the owner.
     * This function is called automatically when the contract is deployed.
     * We use this approach instead of a constructor as requested.
     */
    function setOwner() public {
        if (owner == address(0)) {
            owner = msg.sender;
        }
    }

    /**
     * @notice Starts a new voting session with a given proposal.
     * @dev Resets all previous voting data. Can only be called by the owner.
     * @param _proposalText The text of the proposal to be voted on.
     */
    function startVoting(string memory _proposalText) public onlyOwner {
        proposal = _proposalText;
        votingOpen = true;
        positiveVotes = 0;
        negativeVotes = 0;
        neutralVotes = 0;
        sentimentScore = 0;
        // Note: The 'hasVoted' mapping is not reset automatically, 
        // which means users can only vote once per contract deployment.
        // For a multi-proposal system, a reset mechanism would be needed here.
        emit ProposalSet(_proposalText);
    }

    /**
     * @notice Updates the sentiment score.
     * @dev This is intended to be called by an oracle or a trusted owner.
     * @param _newScore The new sentiment score, clamped between -100 and 100.
     */
    function updateSentiment(int256 _newScore) public onlyOwner whenVotingIsOpen {
        require(_newScore >= -100 && _newScore <= 100, "Score must be between -100 and 100.");
        sentimentScore = _newScore;
        emit SentimentUpdated(_newScore);
    }

    /**
     * @notice Cast a vote for the current proposal.
     * @param _vote The vote option (0 for Negative, 1 for Neutral, 2 for Positive).
     */
    function castVote(VoteOption _vote) public whenVotingIsOpen {
        require(!hasVoted[msg.sender], "You have already voted.");
        
        hasVoted[msg.sender] = true;

        if (_vote == VoteOption.Positive) {
            positiveVotes++;
        } else if (_vote == VoteOption.Negative) {
            negativeVotes++;
        } else {
            neutralVotes++;
        }
        
        emit VoteCast(msg.sender, _vote);
    }

    /**
     * @notice Ends the voting session and calculates the result.
     * @dev Applies the sentiment score as a weight to the vote counts.
     */
    function endVoting() public onlyOwner whenVotingIsOpen {
        votingOpen = false;

        // Calculate weighted scores. Using 1000 as a base for precision.
        uint256 positiveWeight = uint256(1000 + sentimentScore);
        uint256 negativeWeight = uint256(1000 - sentimentScore);

        // Apply weights. The result is scaled by 1000.
        uint256 finalPositiveTally = positiveVotes * positiveWeight;
        uint256 finalNegativeTally = negativeVotes * negativeWeight;
        
        string memory outcome;
        if (finalPositiveTally > finalNegativeTally) {
            outcome = "Proposal Passed";
        } else if (finalNegativeTally > finalPositiveTally) {
            outcome = "Proposal Failed";
        } else {
            outcome = "Tie";
        }
        
        emit VotingEnded(finalPositiveTally, finalNegativeTally, outcome);
    }

    /**
     * @notice Gets the current state of the vote counts.
     * @return pVotes The total number of positive votes.
     * @return nVotes The total number of negative votes.
     * @return neuVotes The total number of neutral votes.
     */
    function getVoteCounts() public view returns (uint256 pVotes, uint256 nVotes, uint256 neuVotes) {
        return (positiveVotes, negativeVotes, neutralVotes);
    }
}
